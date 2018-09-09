//
//  OrderItemDetailView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import FontAwesomeKit

/// The detail information of an order item.
class OrderItemDetailView: KLView {
    var theme: Theme = Theme.mainTheme
    
    var normalFont: UIFont!
    var boldFont: UIFont!
    var subFont: UIFont!
    
    // Trigger to setup font in first time
    var size: OrderItemSize = OrderItemSize.normal {
        didSet {
            //guard size != oldValue else { return }
            normalFont = theme.orderItemFont(self.size)
            boldFont = theme.orderItemBoldFont(self.size)
            subFont = theme.orderItemSubFont(self.size)
            count.font = boldFont
            name.font = normalFont
            amount.font = normalFont
            xl.font = normalFont
            note.font = subFont
            noteAmount.font = subFont
            for (name, amount) in options {
                name.font = subFont
                amount.font = subFont
            }
            void.font = subFont
            setNeedsLayout()
        }
    }
    
    let name = UILabel()
    let amount = UILabel()
    
    let count = UILabel()
    let xl = UILabel()
    
    var options: [(UILabel, UILabel)] = []
    
    let updatedIcon = UILabel()
    let togoIcon = UILabel()
    let holdIcon = UILabel()
    
    let note = UILabel()
    let noteAmount = UILabel()
    
    let void = UILabel()
    
    /// Area of this cell.
    var orderItem: OrderItem? {
        didSet {
            setNeedsLayout()
        }
    }
    
    func optionLabels(at index: Int) -> (UILabel, UILabel) {
        if index < options.count { return options[index] }
        let name = UILabel()
        name.textColor = theme.textColor
        name.font = subFont
        name.alpha = 0.7
        name.numberOfLines = 0
        name.lineBreakMode = .byWordWrapping
        addSubview(name)
        let amount = UILabel()
        amount.textColor = theme.textColor
        amount.font = subFont
        amount.textAlignment = .right
        amount.alpha = 0.7
        addSubview(amount)
        options.append((name, amount))
        return (name, amount)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set all to hidden
        for v in subviews {
            v.isHidden = true
        }
        // Nothing to update, then just return
        guard let item = orderItem else {
            return
        }
        
        let frame = self.frame
        let normalFont = self.normalFont ?? theme.normalFont
        let subFont = self.subFont ?? theme.smallFont
        let contentLeft: CGFloat = 32 + 16
        let amountW: CGFloat = 64
        let amountL = frame.width - amountW
        let nameW = frame.width - 112
        let (nameHeight, subHeights, subHeight, height) = getHeight(forItemDetailCell: item, nfont: normalFont, sfont: subFont, nameW: nameW)
        var y = (frame.height - height) / 2 + oiVerPadding
        
        
        // ROW 1
        count.isHidden = false
        count.text = String(format: "%.0f", item.count)
        count.frame = CGRect(x: 0, y: y, width: 32, height: subHeight)
        
        xl.isHidden = false
        xl.text = "x"
        xl.frame = CGRect(x: 32, y: y, width: 16, height: subHeight)
        
        amount.isHidden = false
        amount.text = item.samelineSubtotal.asMoney
        amount.frame = CGRect(x: amountL, y: y, width: amountW, height: subHeight)
        
        name.isHidden = false
        name.text = item.samelineName
        name.numberOfLines = 0
        name.lineBreakMode = .byWordWrapping
        name.frame = CGRect(x: contentLeft, y: y, width: nameW, height: nameHeight)
        y += nameHeight + oiLineSpace
        
        // ROW 2
        if item.togo {
            togoIcon.isHidden = false
            togoIcon.frame = CGRect(x: contentLeft, y: y, width: oiIconSize, height: oiIconSize)
        }
        if item.hold {
            holdIcon.isHidden = false
            holdIcon.frame = CGRect(x: contentLeft + oiIconWithPad, y: y, width: oiIconSize, height: oiIconSize)
        }
        if item.isUpdated {
            updatedIcon.isHidden = false
            updatedIcon.frame = CGRect(x: contentLeft + oiIconWithPad * 2, y: y, width: oiIconSize, height: oiIconSize)
        }
        if item.isUpdated || item.togo || item.hold {
            y += oiIconSize + oiLineSpace
        }
        
        // ROW 3
        if item.hasNote {
            let noteHeight = item.note.height(withConstrainedWidth: oiNoteWidth, font: note.font)
            noteAmount.isHidden = false
            noteAmount.text = item.noteSubtotal.asMoney
            noteAmount.frame = CGRect(x: amountL, y: y, width: amountW, height: noteHeight)
            
            note.isHidden = false
            note.text = item.note
            note.frame = CGRect(x: contentLeft, y: y, width: nameW, height: noteHeight)
            
            y += noteHeight + oiLineSpace
        }
        
        let subSize = CGSize(width: nameW, height: CGFloat.greatestFiniteMagnitude)
        let amountSubHeight = "WILLBE".boundingRect(with: subSize, attributes: [NSAttributedStringKey.font: subFont], context: nil).height
        for (index, item) in item.options.enumerated() {
            let (name, amount) = item
            let (nameLabel, amountLabel) = optionLabels(at: index)
            amountLabel.isHidden = false
            amountLabel.text = amount.asMoney
            let calSubHeight = subHeights[index]
            amountLabel.frame = CGRect(x: amountL, y: y, width: amountW, height: amountSubHeight)
            
            nameLabel.isHidden = false
            nameLabel.numberOfLines = 0
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.text = name
            nameLabel.frame = CGRect(x: contentLeft, y: y, width: nameW, height: calSubHeight)
            
            y += calSubHeight
        }
        
        // ROW 4
        if item.voidReason.isNotEmpty {
            void.isHidden = false
            void.text = item.voidReason
            void.frame = CGRect(x: contentLeft, y: y, width: nameW  + amountW, height: subHeight)
            y += subHeight + oiLineSpace
        }
    }
    
    override func prepare() {
        super.prepare()
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        count.font = boldFont
        count.textColor = theme.textColor
        count.textAlignment = .right
        addSubview(count)
        
        xl.font = normalFont
        xl.textColor = theme.textColor
        xl.textAlignment = .center
        addSubview(xl)
        
        name.font = normalFont
        name.textColor = theme.textColor
        addSubview(name)
        
        amount.font = normalFont
        amount.textAlignment = .right
        amount.textColor = theme.textColor
        addSubview(amount)
        
        updatedIcon.textColor = theme.warn.base
        updatedIcon.fakIcon = FAKFontAwesome.pencilSquareIcon(withSize: 20.0)
        addSubview(updatedIcon)
        
        togoIcon.textColor = theme.secondary.base
        togoIcon.fakIcon = FAKFontAwesome.truckIcon(withSize: 20.0)
        addSubview(togoIcon)
        
        holdIcon.textColor = theme.warn.base
        holdIcon.fakIcon = FAKFontAwesome.handPaperOIcon(withSize: 20.0)
        addSubview(holdIcon)
        
        note.font = subFont ?? theme.smallFont
        note.textColor = theme.textColor
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        note.alpha = 0.7
        addSubview(note)
        
        noteAmount.font = subFont ?? theme.smallFont
        noteAmount.textColor = theme.textColor
        noteAmount.alpha = 0.7
        noteAmount.textAlignment = .right
        addSubview(noteAmount)
        
        void.font = subFont ?? theme.smallFont
        void.textColor = theme.warn.base
        addSubview(void)
    }
}

fileprivate let oiAmountWidth: CGFloat = 64
fileprivate let oiLineSpace: CGFloat = 4
fileprivate let oiIconSize: CGFloat = 20
fileprivate let oiIconWithPad: CGFloat = 20 + 8
fileprivate let oiVerPadding: CGFloat = 8
fileprivate let oiNoteWidth: CGFloat = 136

/// Calculate cell height for OrderItem and its font
func getHeight(forItemDetailCell item: OrderItem, nfont: UIFont, sfont: UIFont, nameW: CGFloat) -> (CGFloat, [CGFloat], CGFloat, CGFloat) {
    let size = CGSize(width: nameW, height: CGFloat.greatestFiniteMagnitude)
    let nameHeight = NSString(string: item.samelineName).boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : nfont], context: nil).size.height
    let subHeight = "WILLBE".boundingRect(with: size, attributes: [NSAttributedStringKey.font: nfont], context: nil).height
    let noteHeight = item.note.height(withConstrainedWidth: oiNoteWidth, font: sfont)
    var height: CGFloat = 0.0
    height += nameHeight + oiLineSpace
    // Icon status
    if item.isUpdated || item.togo || item.hold {
        height += oiIconSize + oiLineSpace
    }
    // Note
    if item.hasNote {
        height += noteHeight + oiLineSpace
    }
    
    // item height
    var subHeights: [CGFloat] = []
    var totalSubHeight: CGFloat = 0
    for (_, item) in item.options.enumerated() {
        let (name, _) = item
        let calSubHeight = NSString(string: name).boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : sfont], context: nil).size.height
        print("\(name) = \(calSubHeight)")
        subHeights.append(calSubHeight)
        totalSubHeight += calSubHeight
    }
    height += totalSubHeight
    
    if item.isVoided {
        height += subHeight + oiLineSpace
    }
    height += oiVerPadding * 2
    return (nameHeight, subHeights, subHeight, height)
}
