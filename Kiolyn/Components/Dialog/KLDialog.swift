//
//  Dialog.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 2/24/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture
import Material
import FontAwesomeKit

/// The dialog toolbar.
class KLDialogToolbar: Bar {
    let theme = Theme.dialogTheme
    
    let title = UILabel()
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: max(size.height, theme.dialogToolbarHeight))
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = theme.headerBackground
        layoutEdgeInsets = EdgeInsets(top: 4, left: 8, bottom: 4, right: 0)
        
        title.textColor = theme.headerTextColor
        title.font = theme.heading1Font
        
        leftViews = [title]
    }
}

/// The father of all dialogs. Should not be used directly but instead inherit and override the makeContentView method to layout custom content.
class KLDialog<T>: KLView {

    // MARK: - UI components
    
    let theme = Theme.dialogTheme
    let disposeBag = DisposeBag()

    /// The correspondence view model
    private let viewModel: DialogViewModel<T>

    lazy var rootView: UIView = self.makeRootView()
    lazy var dialogView: UIView = self.makeDialogView()
    lazy var dialogToolbar: UIView? = self.makeDialogToolbar()
    lazy var dialogCloseButton: FlatButton = self.makeDialogCloseButton()
    lazy var dialogContentView: UIView? = self.makeDialogContentView()
    lazy var dialogBottomBar: Bar? = self.makeDialogBottomBar()
    lazy var keyboardView: UIView? = self.makeKeyboard()
    
    lazy var numpad: KLKeyboard = Numpad()
    lazy var cashKeyboard: KLKeyboard = {
        let cashKeyboard = CashKeyboard()
        cashKeyboard.openCashDrawerKey.rx.tap
            .subscribe(onNext: { SP.printingService.openCashDrawer() })
            .disposed(by: self.disposeBag)
        return cashKeyboard
    }()
    lazy var textKeyboard: KLKeyboard = QwertyKeyboard()
    
    
    // MARK: - Dialog configuration
    
    /// Return the height of toolbar.
    var toolbarHeight: CGFloat { return dialogToolbar != nil ? theme.dialogToolbarHeight : 0 }
    /// Return the height of bottom bar.
    var bottomBarHeight: CGFloat { return dialogBottomBar != nil ? theme.buttonHeight : 0 }
    /// Return the min with of dialog content (not including keyboard).
    var dialogWidth: CGFloat { return 480 }
    /// Return the min height of dialog content (not including keyboard).
    var dialogHeight: CGFloat { return 520 }
    /// Return the min height of dialog content (not including keyboard).
    var keyboardOffset: CGFloat { return keyboard != nil ? theme.guideline * 2 : 0 }
    /// The width of keyboard
    private var keyboardWidth: CGFloat { return CGFloat(self.keyboard?.expectedWidth ?? 0) }
    /// The width of keyboard
    private var keyboardHeight: CGFloat { return CGFloat(self.keyboard?.expectedHeight ?? 0) }
    /// The total with of dialog content and keyboard
    private var totalWidth: CGFloat { return dialogWidth + keyboardWidth + keyboardOffset }
    /// The total with of dialog content and keyboard
    private var totalHeight: CGFloat { return max(dialogHeight, keyboardHeight) }
    
    /// The text fields and required keyboard type mapping.
    var textFields: [(KLTextField, KLKeyboard)] { return [] }
    
    /// Return the keyboards used inside this dialog.
    fileprivate lazy var keyboards: Set<KLKeyboard> = { return Set(self.textFields.map { $0.1 }) }()
    
    /// Hold the current keyboard.
    var keyboard: KLKeyboard? {
        didSet {
            guard keyboard != oldValue else { return }
            // Hide/Show keyboards
            for kb in self.keyboards {
                kb.isHidden = kb != self.keyboard
            }
            UIView.animate(withDuration: 0.2) {
                self.update()
                self.rootView.setNeedsLayout()
            }
        }
    }

    // MARK: - Initializations
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<T>) {
        self.viewModel = vm
        super.init(frame: .zero)
    }

    // MARK: - Build layout element
    
    /// Build the root view
    ///
    /// - Returns: The root view.
    func makeRootView() -> UIView {
        let view = UIView()
        // Add dialog view
        view.addSubview(self.dialogView)
        // Add keyboard view
        if let keyboard = self.keyboardView {
            view.addSubview(keyboard)
        }
        return view
    }
    
    /// Build the dialog view
    ///
    /// - Returns: The dialog content view.
    func makeDialogView() -> UIView {
        let dialog = UIView()
        
        dialog.backgroundColor = theme.backgroundColor
        dialog.layer.cornerRadius = 2.0
        dialog.clipsToBounds = true
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.alignment = .fill
        wrapper.spacing = 0
        wrapper.distribution = .fill

        // The toolbar
        if let toolbar = self.dialogToolbar {
            toolbar.setContentHuggingPriority(.defaultHigh, for: .vertical)
            wrapper.addArrangedSubview(toolbar)
        }
        // the content
        if let content = self.dialogContentView {
            wrapper.addArrangedSubview(content)
        }
        // the bottom bar
        if let bottomBar = self.dialogBottomBar {
            bottomBar.setContentHuggingPriority(.defaultHigh, for: .vertical)
            wrapper.addArrangedSubview(bottomBar)
        }
        
        dialog.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return dialog
    }
    
    /// Build the dialog toolbar.
    ///
    /// - Returns: A toolbar.
    func makeDialogToolbar() -> UIView? {
        let toolbar = KLDialogToolbar()
        toolbar.rightViews = [dialogCloseButton]
        viewModel.dialogTitle
            .asDriver()
            .drive(toolbar.title.rx.text)
            .disposed(by: disposeBag)
        // Bind it to close message
        dialogCloseButton.rx.tap
            .map { _ -> T? in self.viewModel.dialogResult }
            .bind(to: self.viewModel.closeDialog)
            .disposed(by: disposeBag)
        return toolbar
    }
    
    /// Create the dialog close.
    ///
    /// - Returns: Dialog closed button.
    func makeDialogCloseButton() -> FlatButton {
        let button = KLFlatButton()
        button.pulseAnimation = .centerWithBacking
        button.setTitleColor(theme.headerTextColor, for: .normal)
        button.fakIcon = FAKFontAwesome.timesIcon(withSize: 28.0)
        // Bind it to close message
        button.rx.tap
            .map { _ -> T? in self.viewModel.dialogResult }
            .bind(to: viewModel.closeDialog)
            .disposed(by: disposeBag)
        return button
    }

    /// Build the keyboard view
    ///
    /// - Returns: The keyboard container view.
    func makeKeyboard() -> UIView? {
        let view = UIView()
        view.clipsToBounds = true
        for keyboard in keyboards {
            view.addSubview(keyboard)
            keyboard.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            // Bind the return button
            if let returnButton = keyboard.returnButton {
                viewModel.canSave
                    .startWith(false)
                    .bind(to: returnButton.rx.isEnabled)
                    .disposed(by: disposeBag)
                returnButton.rx.tap
                    .bind(to: viewModel.save )
                    .disposed(by: disposeBag)
            }
        }
        for (tf, kb) in textFields {
            // Assign text field to keyboard's own text fields
            kb.textFields.append(tf)
            // Hook to becoming first responder
            tf.rx.controlEvent(.didBecomeFirstResponder)
                .subscribe(onNext: { _ in self.keyboard = kb })
                .disposed(by: disposeBag)
        }
        
        // Now override the navigaiton handler's text fields to trick the navigation handler to go cross keyboards.
        for keyboard in keyboards {
            keyboard.navigationHandler.textFields = textFields.map { $0.0 }
        }
        return view
    }
    
    /// Generic content view
    ///
    /// - Returns: The empty content view.
    func makeDialogContentView() -> UIView? {
        return nil
    }
    
    /// Create the bottom bar.
    ///
    /// - Returns: Bottom bar.
    func makeDialogBottomBar() -> Bar? {
        return nil
    }
    
    /// Setup the layout
    override func prepare() {
        super.prepare()
        // Transparent background
        self.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        // Build dialog view (including Dialog Content & Keyboard)
        self.addSubview(self.rootView)
    }
    
    /// Relayout the RootView, DialogView, KeyboardView
    private func update() {
        let frame = self.frame
        let w = frame.size.width
        let h = frame.size.height
        let tw = self.totalWidth
        let th = self.totalHeight
        let dw = self.dialogWidth
        let dh = self.dialogHeight
        let kw = self.keyboardWidth
        let kh = self.keyboardHeight
        self.rootView.frame = CGRect(x: (w - tw) / 2, y: (h - th) / 2, width: tw, height: th)
        self.dialogView.frame = CGRect(x: 0, y: (th - dh) / 2, width: dw, height: dh)
        if let keyboard = self.keyboardView {
            keyboard.frame = CGRect(x: tw - kw, y: (th - kh) / 2, width: kw, height: kh)
        }
    }
    
    /// Show the dialog with Single result.
    ///
    /// - Returns: Single of the dialog result.
    func show() -> Single<T?> {
        return Single<T?>.create { single -> Disposable in
            guard let parent = UIApplication.shared.keyWindow else {
                single(.success(nil))
                return Disposables.create()
            }
            self.viewModel.closeDialog
                .asDriver(onErrorJustReturn: nil)
                .drive(onNext: { dialogResult -> Void in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.rootView.transform = CGAffineTransform(scaleX: 0, y: 0)
                        self.rootView.alpha = 0
                        self.rootView.layoutIfNeeded()
                    }, completion: { _ in
                        self.removeFromSuperview()
                        single(.success(dialogResult))
                        // Close explicitly to prevent multiple closing
                        self.viewModel.closeDialog.onCompleted()
                    })
                })
                .disposed(by: self.disposeBag)

            // Add to parent view
            parent.addSubview(self)
            self.frame = parent.frame
            
            self.rootView.alpha = 0 
            self.update()
            self.rootView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            // ... give a chance to load data
            DispatchQueue.main.async {
                self.viewModel.dialogWillAppear.onNext(())
            }
            // Animate the root view in
            UIView.animate(withDuration: 0.2, animations: {
                self.rootView.alpha = 1
                self.rootView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.rootView.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.async {
                    self.viewModel.dialogDidAppear.onNext(())
                }
            })
            return Disposables.create()
        }
    }
}
