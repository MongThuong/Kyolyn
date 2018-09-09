//
//  EditOrderItemDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/9/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Material
import FontAwesomeKit

class EditOrderItemDialog: KLDialog<(OrderItem, Order)> {
    
    private var viewModel: EditOrderItemDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<(OrderItem, Order)>) {
        guard let vm = vm as? EditOrderItemDVM else {
            fatalError("Expecting EditOrderItemDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    // MARK: - UI
    
    let subtotal = UILabel()
    let nameView = UIView()
    let nameLabel = UILabel()
    let nameText = KLTextField()
    var itemImage: OrderItemImageButton!
    
    let wrapper = UIStackView()
    
    let row1 = UIView()
    let empty = UIView()
    let countView = UIView()
    let count = KLUIntField()
    let increase = FlatButton()
    let decrease = FlatButton()
    let price = KLCashField()
    
    let row2 = UIView()
    let note = KLTextField()
    let priceNote = KLCashField()
    
    let togoView = UIView()
    let togoLabel = UILabel()
    let togo = KLToggleButton()
    
    var collection: Material.CollectionView!
    
    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }
    
    /// Return the keyboard mapping
    override var textFields: [(KLTextField, KLKeyboard)] {
        var fields: [(KLTextField, KLKeyboard)] = []
        if viewModel.orderItem.isOpenItem {
            fields.append((nameText, textKeyboard))
        }
        return fields +
            [(count, numpad),
             (price, numpad),
             (note, textKeyboard),
             (priceNote, numpad)]
    }
    
    override func makeDialogToolbar() -> UIView? {
        let toolbar = UIView()
        toolbar.backgroundColor = theme.headerBackground
        toolbar.layoutEdgeInsets = EdgeInsets(top: 4, left: 12, bottom: 4, right: 4)
        // IMAGE
        itemImage = OrderItemImageButton(theme)
        toolbar.addSubview(itemImage)
        // CLOSE
        toolbar.addSubview(dialogCloseButton)
        // SUBTOTAL
        subtotal.textColor = theme.headerTextColor
        subtotal.font = theme.heading1BoldFont
        subtotal.textAlignment = .right
        toolbar.addSubview(subtotal)
        // NAME
        toolbar.addSubview(nameView)
        
        nameLabel.textColor = theme.headerTextColor
        nameLabel.font = theme.heading1Font
        nameView.addSubview(nameLabel)
        
        nameText.textColor = theme.headerTextColor
        nameText.dividerColor = theme.headerSecondaryTextColor
        nameText.dividerActiveColor = theme.headerTextColor
        nameText.font = theme.heading3Font
        nameText.placeholder = "Name"
        nameText.placeholderNormalColor = theme.headerSecondaryTextColor
        nameText.placeholderActiveColor = theme.headerTextColor
        nameText.placeholderActiveScale = 0.4
        nameText.placeholderVerticalOffset = 24.0
        nameView.addSubview(nameText)
        
        toolbar.addSubview(nameView)
        
        return toolbar
    }
    
    override func makeDialogContentView() -> UIView? {
        // ROW 1 - EMPTY
        row1.addSubview(empty)
        // ROW 1 - COUNT
        row1.addSubview(countView)
        decrease.setTitleColor(theme.primary.base, for: .normal)
        decrease.fakIcon = FAKFontAwesome.minusIcon(withSize: 16.0)
        countView.addSubview(decrease)
        increase.setTitleColor(theme.primary.base, for: .normal)
        increase.fakIcon = FAKFontAwesome.plusIcon(withSize: 16.0)
        countView.addSubview(increase)
        count.placeholder = "Quantity"
        count.font = theme.xlargeInputFont
        count.minValue = 0
        count.maxValue = 99
        count.placeholderActiveScale = 0.5
        count.placeholderVerticalOffset = 28.0
        count.textColor = theme.textColor
        countView.addSubview(count)
        // ROW 1 - PRICE
        price.placeholder = "Item Price"
        price.font = theme.xlargeInputFont
        price.placeholderActiveScale = 0.5
        price.placeholderVerticalOffset = 28.0
        price.textColor = theme.textColor
        row1.addSubview(price)
        
        // ROW 2 - TOGO
        row2.addSubview(togoView)
        togo.setTitleColor(theme.primary.base, for: .normal)
        togo.fakIcon = FAKFontAwesome.truckIcon(withSize: 16.0)
        togoView.addSubview(togo)
        togoLabel.font = theme.xsmallFont
        togoLabel.textColor = theme.primary.base
        togoLabel.text = "TOGO"
        togoView.addSubview(togoLabel)
        // ROW 2 - NOTE
        // For fixing #KIO-757 https://willbe.atlassian.net/browse/KIO-757
        note.placeholder = "Note 0/100"
        note.font = theme.xlargeInputFont
        note.placeholderActiveScale = 0.5
        note.placeholderVerticalOffset = 28.0
        note.textColor = theme.textColor
        row2.addSubview(note)
        // ROW 2- PRICE NOTE
        priceNote.placeholder = "Note Price"
        priceNote.font = theme.xlargeInputFont
        priceNote.placeholderActiveScale = 0.5
        priceNote.placeholderVerticalOffset = 28.0
        priceNote.textColor = theme.textColor
        
        row2.addSubview(priceNote)
        
        // ROW 3 - COLLECTION
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 96, height: 64)
        layout.headerReferenceSize = CGSize(width: 320, height: theme.normalInputHeight)
        collection = Material.CollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(OptionCollectionViewCell.self, forCellWithReuseIdentifier: "OptionCell")
        collection.register(PrinterCollectionViewCell.self, forCellWithReuseIdentifier: "PrinterCell")
        collection.register(ModifierCollectionTitleView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Title")
        
        // GENERAL CONTENT
        let content = UIView()
        content.addSubview(wrapper)
        wrapper.axis = .vertical
        wrapper.distribution = .fill
        wrapper.alignment = .fill
        wrapper.spacing = theme.guideline*3
        row1.setContentHuggingPriority(.defaultLow, for: .vertical)
        row2.setContentHuggingPriority(.defaultLow, for: .vertical)
        wrapper.addArrangedSubview(row1)
        wrapper.addArrangedSubview(row2)
        wrapper.addArrangedSubview(collection)
        return content
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        itemImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(theme.guideline)
            make.width.height.equalTo(theme.smallIconButtonWidth)
        }
        dialogCloseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
            make.width.equalTo(theme.normalButtonHeight)
        }
        subtotal.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(dialogCloseButton.snp.leading).offset(-theme.guideline*2)
            make.width.equalTo(120)
        }
        nameView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(theme.guideline + 4)
            make.bottom.equalToSuperview().offset(-theme.guideline-4)
            make.leading.equalTo(itemImage.snp.trailing).offset(theme.guideline)
            make.trailing.equalTo(subtotal.snp.leading).offset(-theme.guideline*2)
        }
        nameText.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        row1.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(theme.buttonHeight)
        }
        row2.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(theme.buttonHeight)
        }
        wrapper.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(theme.guideline*2)
            make.left.equalToSuperview().offset(theme.guideline)
            make.right.bottom.equalToSuperview().offset(-theme.guideline)
        }
        empty.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        countView.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.leading.equalTo(empty.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        decrease.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.height.equalTo(theme.smallIconButtonWidth)
        }
        increase.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.height.equalTo(theme.smallIconButtonWidth)
        }
        count.snp.makeConstraints { make in
            make.leading.equalTo(decrease.snp.trailing).offset(theme.guideline/2)
            make.trailing.equalTo(increase.snp.leading).offset(-theme.guideline/2)
            make.height.centerY.equalToSuperview()
        }
        price.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
            make.leading.equalTo(countView.snp.trailing).offset(theme.guideline*2)
        }
        
        togoView.snp.makeConstraints { make in
            make.centerY.leading.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        togo.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.height.equalTo(theme.smallIconButtonWidth)
        }
        togoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(togo.snp.centerX)
            make.bottom.equalTo(togo.snp.top).offset(-2)
        }
        note.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.leading.equalTo(togoView.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        priceNote.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
            make.leading.equalTo(note.snp.trailing).offset(theme.guideline*2)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        guard let orderItem = viewModel.orderItem else {
            return
        }
        
        // Initial values
        itemImage.orderItem = orderItem
        nameText.isHidden = !orderItem.isOpenItem
        nameLabel.isHidden = orderItem.isOpenItem
        viewModel.samelineName.asDriver()
        .drive(self.nameLabel.rx.text)
        .disposed(by: disposeBag)
        nameText.text = orderItem.name
        subtotal.text = orderItem.subtotal.asMoney
        count.value = UInt(orderItem.count)
        price.value = orderItem.price
        note.text = orderItem.note
        // For fixing #KIO-757 https://willbe.atlassian.net/browse/KIO-757
        if let noteText = note.text {
            note.placeholder = "Note \(noteText.count)/100"
        }
        priceNote.value = orderItem.priceNote
        togo.isSelected = orderItem.togo
        
        // Disable everything if the order item cannot be edited
        guard viewModel.canEdit else {
            dialogContentView?.isUserInteractionEnabled = false
            dialogContentView?.alpha = 0.5
            return
        }
        // Deeper editing permission
        nameText.isEnabled = viewModel.canEditName
        price.isEnabled = viewModel.canEditPrice
        
        _ = viewModel.dialogDidAppear
            .subscribe(onNext: { _ in
                guard self.viewModel.canEdit else { return }
                if orderItem.isOpenItem {
                    _ = self.nameText.becomeFirstResponder()
                } else {
                    _ = self.count.becomeFirstResponder()
                }
            })
        
        nameText.rx.text.orEmpty.changed
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        count.rx.value
            .asObservable()
            .map { Double($0) }
            .bind(to: viewModel.count)
            .disposed(by: disposeBag)
        price.rx.doubleValue
            .asDriver()
            .drive(viewModel.price)
            .disposed(by: disposeBag)
        // For fixing #KIO-757 https://willbe.atlassian.net/browse/KIO-757
        note.rx.text.orEmpty.changed
            .map { text in
                var stringText = text
                if stringText.count > 100 {
                    stringText = (stringText as NSString).substring(to: 100)
                }
                self.note.placeholder = "Note \(stringText.count)/100"
                self.note.text = stringText
                return stringText
            }
            .bind(to: viewModel.note)
            .disposed(by: disposeBag)
        priceNote.rx.doubleValue
            .asDriver()
            .drive(viewModel.priceNote)
            .disposed(by: disposeBag)
        togo.rx.tap
            .map { self.togo.isSelected }
            .bind(to: viewModel.togo)
            .disposed(by: disposeBag)
        
        viewModel.subtotal
            .asDriver()
            .map { $0.asMoney }
            .drive(subtotal.rx.text)
            .disposed(by: disposeBag)
        
        decrease.rx.tap
            .subscribe(onNext: { self.count.apply(key: .minus(1)) })
            .disposed(by: disposeBag)
        increase.rx.tap
            .subscribe(onNext: { self.count.apply(key: .add(1)) })
            .disposed(by: disposeBag)
        if orderItem.isOpenItem {
            let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Selectable<Printer>>>(
                configureCell: { (dataSource, collectionView, indexPath, sp) in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrinterCell", for: indexPath) as! PrinterCollectionViewCell
                    cell.printer = sp.item
                    cell.isSelected = sp.isSelected
                    return cell
            }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Title", for: indexPath) as! ModifierCollectionTitleView
                cell.titleLabel.text = "Printers"
                return cell
            })
            viewModel.printers
                .asDriver()
                .map { [SectionModel(model: "Printers", items: $0)] }
                .drive(collection.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            collection.rx.modelSelected(Selectable<Printer>.self)
                .map { sp in sp.isSelected = !sp.isSelected }
                .withLatestFrom(viewModel.printers.asObservable())
                .bind(to: viewModel.printers)
                .disposed(by: disposeBag)
        } else {
            let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<Modifier, Selectable<Option>>>(
                configureCell: { (dataSource, collectionView, indexPath, so) in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCollectionViewCell
                    cell.option = so.item
                    cell.isSelected = so.isSelected
                    return cell
            }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Title", for: indexPath) as! ModifierCollectionTitleView
                let element = dataSource.sectionModels[indexPath.section]
                cell.titleLabel.text = element.model.nameWithRequired
                return cell
            })
            viewModel.modifiers
                .asDriver()
                .map { $0.map { (modifier, options) in SectionModel(model: modifier, items: options) } }
                .drive(collection.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            collection.rx.itemSelected
                .map { indexPath -> Void in
                    let element = dataSource.sectionModels[indexPath.section]
                    let modifier = element.model
                    let options = element.items
                    if modifier.multiple {
                        let opt = options[indexPath.item]
                        opt.isSelected = !opt.isSelected
                    } else {
                        for (index, opt) in options.enumerated() {
                            opt.isSelected = index == indexPath.item
                        }
                    }
                }
                .withLatestFrom(viewModel.modifiers.asObservable())
                .bind(to: viewModel.modifiers)
                .disposed(by: disposeBag)
        }
    }
}
