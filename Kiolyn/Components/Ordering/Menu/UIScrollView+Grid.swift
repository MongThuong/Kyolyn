//
//  UIScrollView+Grid.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Extension for organizing as grid for Categories/Items/Options.
extension UIScrollView {
    
    /// Add a button for GridObjectViewModel with
    ///
    /// - Parameters:
    ///   - item: The item to add to scroll view
    ///   - settings: The grid settings.
    ///   - row: The target row, if not given use the item.row.
    ///   - col: The target col, if not given use the item.col.
    func add<GO, GB:GridButton<GO>>(item: GO, with settings: OrderingGridSettings, at row: Int = -1, col: Int = -1) -> GB {
        let button = GB(object: item, settings: settings)
        let contentView = self.subviews.first!
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(settings.width)
            make.height.equalTo(settings.height)
            let r = row < 0 ? item.row : row
            make.top.equalTo((settings.height + settings.gutter * 2) * r)
            let c = col < 0 ? item.col : col
            make.left.equalTo((settings.width + settings.gutter * 2) * c)
        }
        return button
    }
    
    /// Allocate given items to a UIScrollView.
    ///
    /// - Parameters:
    ///   - items: The items to allocate to grid.
    ///   - settings: The settings to apply
    func allocate<GO, GB:GridButton<GO>>(items: [GO], with settings: OrderingGridSettings) -> [GB] {
        // Cleanup first
        for v in self.subviews {
            v.removeFromSuperview()
        }
        var buttons: [GB] = []
        let totalRow = settings.row
        let totalCol = settings.col
        // Try allocating value to it
        var cells: [[Bool]] = Array(repeating: Array(repeating: false, count: totalCol), count: totalRow)
        // Filter out the bad position object
        let gridItems = items.filter { item in
            !item.hasPosition || (item.row < totalRow && item.col < totalCol)
        }
        // Allocate the items with position first
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height))
        self.addSubview(contentView)
        for item in gridItems {
            guard item.hasPosition else { continue }
            cells[item.row][item.col] = true;
            buttons.append(self.add(item: item, with: settings))
        }
        // Then the one without position
        var freeCol = 0, freeRow = 0
        // Common method for moving to next cell
        let nextCell = { () -> Void in
            // Try the next cell
            freeCol += 1
            // Reach the end of row ... move to next row
            if freeCol == totalCol {
                freeRow += 1
                freeCol = 0
            }
        }
        for item in gridItems {
            guard !item.hasPosition else { continue }
            // Try finding the next empty cell
            while freeRow < totalRow && cells[freeRow][freeCol] {
                nextCell();
                if freeRow >= totalRow { break }
            }
            // A free cell is found
            if freeRow < totalRow {
                // Use the free position
                buttons.append(self.add(item: item, with: settings, at: freeRow, col: freeCol))
                // Move next
                nextCell()
            }
        }
        return buttons
    }
}
