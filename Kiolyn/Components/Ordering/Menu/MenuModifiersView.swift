//
//  MenuModifiersView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For displaying global modifiers view.
class MenuModifiersView: UIView {
    let theme = Theme.dark
    /// The shared bag for disposing
    let disposeBag = DisposeBag()
    /// The cell reuse identifier
    var cellIdentifider: String { return "Cell" }
    /// The open modifier button
    let openModifier = KLPrimaryRaisedButton()
    /// The table view.
    let tableView = KLTableView()
    /// The modifiers view model.
    let viewModel = MenuModifiersViewModel()
    
    // Settings Area
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        // Open modifier button
        openModifier.titleLabel?.numberOfLines = 2
        openModifier.titleLabel?.textAlignment = .center
        let title = NSMutableAttributedString(string: "NEW\n", attributes: [
            NSAttributedStringKey.font: theme.smallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor])
        title.append(NSAttributedString(string: "MODIFIER", attributes: [
            NSAttributedStringKey.font: theme.xsmallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor]))
        openModifier.setAttributedTitle(title, for: .normal)
        openModifier.contentEdgeInsetsPreset = .wideRectangle1
        addSubview(openModifier)
        openModifier.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
        }
        openModifier.rx.tap.bind(to: viewModel.openModifier).disposed(by: disposeBag)
        
        // Add the single view
        addSubview(tableView)
        tableView.rowHeight = theme.mediumButtonHeight
        tableView.register(ModifierCell.self, forCellReuseIdentifier: "Cell")
        tableView.snp.makeConstraints { make in
            make.bottom.width.centerX.equalToSuperview()
        }
        viewModel.modifiers
            .asDriver()
            .drive(tableView.rx.items) { (tableView, row, modifier) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ModifierCell
                cell.textLabel?.text = modifier.name.uppercased()
                cell.disposeBag = DisposeBag()
                self.viewModel.selectedModifier
                    .asDriver()
                    .map { selectedModifier in selectedModifier?.id == modifier.id }
                    .drive(cell.rx.isSelected)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(Modifier.self)
            .asDriver()
            .drive(viewModel.selectedModifier)
            .disposed(by: disposeBag)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        openModifier.snp.makeConstraints { make in
            make.height.equalTo(theme.mediumButtonHeight)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(openModifier.snp.bottom).offset(theme.guideline)
        }
    }
}
