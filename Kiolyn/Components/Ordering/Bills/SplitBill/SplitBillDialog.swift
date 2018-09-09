//
//  SplitBillDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/22/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import SnapKit

/// For splitting a single `Bill` of an `Order`.
class SplitBillDialog: KLDialog<Order> {
    private var viewModel: SplitBillDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Order>) {
        guard let vm = vm as? SplitBillDVM else {
            fatalError("Expecting SplitBillDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    // MARK: - UI
    
    private let countLabel = UILabel()
    private let countView = UIStackView()
    private let countTextField = KLUIntField()
    private let percentageLabel = UILabel()
    private let percentageView = UIStackView()
    private let percentageTextField = KLPercentField()
    private let amountLabel = UILabel()
    private let amountView = UIStackView()
    private let amountTextField = KLCashField()
    
    
    private var countButtons: [SplitTypeButton]?
    private var percentageButtons: [SplitTypeButton]?
    private var amountButtons: [SplitTypeButton]?


    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }

    /// Return the keyboard mapping
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (countTextField, self.numpad),
            (percentageTextField, self.numpad),
            (amountTextField, self.numpad)
        ]
    }
    
    /// Build dialog content here.
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        
        countTextField.font = theme.normalInputFont
        percentageTextField.font = theme.normalInputFont
        amountTextField.font = theme.normalInputFont
        
        countTextField.textColor = theme.textColor
        percentageTextField.textColor = theme.textColor
        amountTextField.textColor = theme.textColor

        countLabel.text = "Split by Number of Bills"
        countLabel.font = theme.heading3Font
        countLabel.textColor = theme.primary.base
        view.addSubview(countLabel)
        countView.axis = .vertical
        countView.alignment = .fill
        countView.distribution = .fillEqually
        countView.spacing = theme.guideline
        countButtons = [2, 3, 4, 5, 6, 7, 8, 9, 10].map {
            SplitTypeButton.new(value: (.count, $0), with: theme)
        }
        countView.add(row: Array(countButtons![0...4]), spacing: theme.guideline)
        countView.add(row: Array(countButtons![5...8]) + [countTextField], spacing: theme.guideline)
        view.addSubview(countView)
        
        
        percentageLabel.text = "Split by Percentage"
        percentageLabel.font = theme.heading3Font
        percentageLabel.textColor = theme.primary.base
        view.addSubview(percentageLabel)
        percentageView.axis = .vertical
        percentageView.alignment = .fill
        percentageView.distribution = .fillEqually
        percentageView.spacing = theme.guideline
        percentageButtons = [0.1, 0.2, 0.3, 0.4, 0.5].map {
            SplitTypeButton.new(value: (.percentage, $0), with: theme)
        }
        percentageView.add(row: Array(percentageButtons![0...2]), spacing: theme.guideline)
        percentageView.add(row: Array(percentageButtons![3...4]) + [percentageTextField], spacing: theme.guideline)
        view.addSubview(percentageView)

        amountLabel.text = "Split by Amount"
        amountLabel.font = theme.heading3Font
        amountLabel.textColor = theme.primary.base
        view.addSubview(amountLabel)
        amountView.axis = .vertical
        amountView.alignment = .fill
        amountView.distribution = .fillEqually
        amountView.spacing = theme.guideline
        amountButtons = [10, 20, 30, 40, 50, 60, 70, 80, 90].map {
            SplitTypeButton.new(value: (.amount, $0), with: theme)
        }
        amountView.add(row: Array(amountButtons![0...4]), spacing: theme.guideline)
        amountView.add(row: Array(amountButtons![5...8]) + [amountTextField], spacing: theme.guideline)
        view.addSubview(amountView)
        
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalToSuperview().offset(theme.guideline)
        }
        countView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(countLabel.snp.bottom).offset(theme.guideline)
            make.height.equalTo(theme.largeButtonHeight*2)
        }
        percentageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(countView.snp.bottom).offset(theme.guideline*2)
        }
        percentageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(percentageLabel.snp.bottom).offset(theme.guideline)
            make.height.equalTo(theme.largeButtonHeight*2)
        }
        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(percentageView.snp.bottom).offset(theme.guideline*2)
        }
        amountView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(amountLabel.snp.bottom).offset(theme.guideline)
            make.height.equalTo(theme.largeButtonHeight*2)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        viewModel.dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.countTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedSplit
            .asDriver()
            .filterNil()
            .drive(onNext: { (type, value) in
                switch type {
                case .count:
                    _ = self.countTextField.becomeFirstResponder()
                    self.countTextField.value = UInt(value)
                    self.percentageTextField.value = 0
                    self.amountTextField.value = 0
                case .percentage:
                    _ = self.percentageTextField.becomeFirstResponder()
                    self.countTextField.value = 0
                    self.percentageTextField.value = value
                    self.amountTextField.value = 0
                case .amount:
                    _ = self.amountTextField.becomeFirstResponder()
                    self.countTextField.value = 0
                    self.percentageTextField.value = 0
                    self.amountTextField.value = value
                }
            })
            .disposed(by: disposeBag)
        
        countTextField.rx.value
            .asDriver()
            .distinctUntilChanged()
            .filter { $0 > 0 }
            .map { (SplitBillType.count, Double($0)) }
            .drive(viewModel.selectedSplit)
            .disposed(by: disposeBag)
        percentageTextField.rx.value
            .asDriver()
            .distinctUntilChanged()
            .filter { $0 > 0 }
            .map { (SplitBillType.percentage, $0) }
            .drive(viewModel.selectedSplit)
            .disposed(by: disposeBag)
        amountTextField.rx.doubleValue
            .asDriver()
            .distinctUntilChanged()
            .filter { $0 > 0 }
            .map { (SplitBillType.amount, $0) }
            .drive(viewModel.selectedSplit)
            .disposed(by: disposeBag)
        
        for b in (countButtons! + percentageButtons! + amountButtons!) {
            b.rx.tap
                .map { b.value }
                .bind(to: viewModel.selectedSplit)
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - Special extension to format the row
fileprivate extension UIStackView {
    func add(row views: [UIView], spacing: CGFloat = 0) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = spacing
        for v in views { row.addArrangedSubview(v) }
        self.addArrangedSubview(row)
    }
}

/// For selecting payment type/sub payment type in Payment Dialog.
fileprivate class SplitTypeButton: KLRaisedButton {
    let disposeBag = DisposeBag()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.largeButtonHeight, height: theme.largeButtonHeight)
    }
    
    override func prepare() {
        super.prepare()
        borderColor = theme.primary.lighten1
        layer.borderWidth = 1.0
        titleLabel?.font = theme.smallFont
    }
    
    var value: (SplitBillType, Double)?
    
    static func new(value: (SplitBillType, Double), with theme: Theme) -> SplitTypeButton {
        let button = SplitTypeButton(theme)
        button.value = value
        switch value.0 {
        case .count:
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.textAlignment = .center
            let title = NSMutableAttributedString(string: "Total\n", attributes: [
                NSAttributedStringKey.font: theme.normalBoldFont,
                NSAttributedStringKey.foregroundColor: theme.secondaryTextColor])
            title.append(NSMutableAttributedString(string: "\n", attributes: [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 2)]))
            title.append(NSAttributedString(string: "\(UInt(value.1))", attributes: [
                NSAttributedStringKey.font: theme.normalBoldFont,
                NSAttributedStringKey.foregroundColor: theme.primary.base]))
            button.setAttributedTitle(title, for: .normal)
            let line = KLLine()
            line.backgroundColor = theme.secondaryTextColor
            button.addSubview(line)
            line.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }
        case .percentage:
            button.title = "\(value.1.asPercentage) + \((1 - value.1).asPercentage)"
        case .amount:
            button.title = "\(value.1.asMoney)"
        }
        
        return button
    }
}
