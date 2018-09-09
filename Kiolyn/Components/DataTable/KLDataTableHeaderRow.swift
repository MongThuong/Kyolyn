//
//  KLDataTableHeaderRow.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying header row
class KLDataTableHeaderRow<T>: KLView {
    var theme: Theme!
    
    private var border = CALayer()
    private var row = KLCellsView()
    private var cells = [UILabel]()
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        super.init(frame: .zero)
        self.theme = theme
        
        backgroundColor = .clear
        
        border = CALayer()
        border.backgroundColor = theme.primary.lighten1.cgColor
        border.opacity = 0.1
        layer.addSublayer(border)
        
        addSubview(row)
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
    
    var columns: [KLDataTableColumn<T>]? = nil {
        didSet {
            // Add new columns
            guard let columns = columns else {
                row.cells = []
                return
            }
            row.cells = columns.map { c in
                let headerLabel = UILabel()
                headerLabel.attributedText = c.name
                headerLabel.numberOfLines = c.lines
                headerLabel.font = theme.xsmallFont
                headerLabel.textColor = theme.secondary.base
                headerLabel.textAlignment = c.type.alignment
                headerLabel.clipsToBounds = false
                return (headerLabel, c.type)
            }
        }
    }
}
