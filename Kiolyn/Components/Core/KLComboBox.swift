//
//  KLComboBox.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/7/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import SnapKit
import DropDown
import FontAwesomeKit

class KLComboBox<T>: FlatButton {
    private let disposeBag = DisposeBag()
    private var theme: Theme!
    
    private let line = UIView()
    private let text = UILabel()
    private let icon = UIImageView()
    private let dropDown = DropDown()
    
    private let iw: CGFloat = 20.0
    private let ih: CGFloat = 20.0

    
    /// Publish to this to update the items (first is display, second is value).
    var items = BehaviorRelay<[(String, T)]>(value: [])
    /// The selected item subject, caller must subscribe to get the value out.
    var selectedItem = BehaviorRelay<(String, T)?>(value: nil)
    
    /// Custom the dropdown with
    var dropDownWidth: CGFloat = 200.0 {
        didSet {
            self.dropDown.width = dropDownWidth
            self.dropDown.setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        text.sizeToFit()
        let tw = text.frame.width
        let th = text.frame.height
        return CGSize(width: max(tw + iw + theme.guideline, 80), height: max(th + 1, theme.normalButtonHeight))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme, placeholder: String = "") {
        self.theme = theme
        super.init(frame: .zero)

        backgroundColor = .clear
        
        text.text = placeholder
        text.font = theme.normalFont
        text.textColor = theme.secondaryTextColor
        text.isUserInteractionEnabled = false
        addSubview(text)
        
        line.backgroundColor = theme.dividersColor
        addSubview(line)
        
        let faIcon = FAKFontAwesome.caretDownIcon(withSize: 20.0)
        faIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: theme.secondaryTextColor)
        faIcon?.addAttribute(NSAttributedStringKey.backgroundColor.rawValue, value: Color.clear)
        icon.image = faIcon?.image(with: CGSize(width: 20, height: 20))
        icon.isUserInteractionEnabled = false
        icon.contentMode = .scaleAspectFit
        addSubview(icon)
        
        dropDown.textColor = theme.textColor
        dropDown.textFont = theme.normalFont
        dropDown.backgroundColor = theme.backgroundColor
        dropDown.anchorView = self
        dropDown.selectionBackgroundColor = theme.secondary.base
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedItem.accept(self.items.value[index])
        }
        dropDown.width = dropDownWidth
        
        rx.tap
            .subscribe(onNext: { self.dropDown.show() })
            .disposed(by: disposeBag)
        
        items
            .asDriver()
            .drive(onNext: { items in
                self.dropDown.dataSource = items.map { $0.0 }
                if items.count > 0 {
                    self.dropDown.selectRow(at: 0)
                    self.selectedItem.accept(self.items.value.first)
                }
                self.dropDown.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        selectedItem
            .asDriver()
            .drive(onNext: { selectedItem in
                if let item = selectedItem {
                    self.text.text = item.0
                } else {
                    self.text.text = ""
                }
                self.invalidateIntrinsicContentSize()
                self.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let w = frame.size.width
        let h = frame.size.height
        line.frame = CGRect(x: 0, y: h - 1, width: w, height: 1)
        icon.frame = CGRect(x: w - iw, y: (h - ih)/2, width: iw, height: ih)
        text.frame = CGRect(x: 0, y: 0, width: w - iw - theme.guideline, height: h - 1)
    }

    override open var isHighlighted: Bool {
        didSet {
            self.line.backgroundColor = isHighlighted ? theme.primary.base : theme.dividersColor
        }
    }
}
