//
//  KLDataTableWithSummary.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For displaying summary row.
class KLDataTableSummary: KLView {
    var theme = Theme.mainTheme
    
    private var border = CALayer()
    private var row = KLCellsView()
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        addSubview(row)
        
        border.backgroundColor = theme.primary.lighten1.cgColor
        border.opacity = 0.1
        layer.addSublayer(border)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        row.snp.makeConstraints { make in
            make.centerX.centerY.height.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: 2, y: frame.height-1, width: frame.width-4, height: 1)
    }
    
    /// Will be set to generate cells
    var cells: [KLDataTableSummaryCell]? = nil {
        didSet {
            guard let columns = self.cells else {
                row.cells = []
                return
            }
            row.cells = columns.map { c in
                let cellLabel = UILabel()
                cellLabel.font = theme.normalBoldFont
                cellLabel.textColor = theme.secondary.base
                cellLabel.textAlignment = c.type.alignment
                return (cellLabel, c.type)
            }
        }
    }
    
    /// Update value for this row.
    var summary: QuerySummary? {
        didSet {
            guard let cells = cells else { return }
            for (index, col) in cells.enumerated() {
                guard index < row.cells.count, let label = row.cells[index].0 as? UILabel else {
                    break
                }
                guard let summary = self.summary else {
                    label.text = ""
                    continue
                }
                label.text = col.value(summary)
            }
        }
    }
}





