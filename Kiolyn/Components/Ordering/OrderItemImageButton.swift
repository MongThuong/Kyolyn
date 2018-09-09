//
//  OrderItemImageButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import FontAwesomeKit
import AlamofireImage

/// For displaying either image or abbreviation together with checking option.
class OrderItemImageButton: FlatButton {
    var theme: Theme!
    /// The image view
    let itemImage = UIImageView()
    let check = UILabel()
    let lock = UILabel()
    // The order item to bind with
    var orderItem: OrderItem? {
        didSet {
            guard let item = orderItem else { return }
            backgroundColor = item.name.color
            if let url = item.image?.url {
                itemImage.af_setImage(withURL: url)
            }
            if item.isBilled {
                lock.fakIcon = FAKFontAwesome.exclamationIcon(withSize: 28.0)
                lock.isHidden = false
            } else if item.isPaid {
                lock.fakIcon = FAKFontAwesome.lockIcon(withSize: 28.0)
                lock.isHidden = false
            } else {
                lock.isHidden = true
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
            }, completion: { _ in
                self.itemImage.isHidden = self.isSelected
                self.check.isHidden = !self.isSelected
                self.layer.transform = CATransform3DIdentity
            })
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 24, height: 24)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        
        shapePreset = .circle
        pulseAnimation = .centerWithBacking
        clipsToBounds = true
        
        itemImage.contentMode = .scaleAspectFill
        itemImage.isUserInteractionEnabled = false
        itemImage.clipsToBounds = true
        addSubview(itemImage)
        itemImage.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        check.isHidden = true
        check.textAlignment = .center
        check.isUserInteractionEnabled = false
        check.clipsToBounds = true
        check.fakIcon = FAKFontAwesome.checkIcon(withSize: 24.0)
        check.textColor = theme.warn.base
        addSubview(check)
        check.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        lock.isHidden = true
        lock.textAlignment = .center
        lock.isUserInteractionEnabled = false
        lock.clipsToBounds = true
        lock.backgroundColor = Color(red: 255, green: 255, blue: 255, alpha: 0.5)
        lock.textColor = theme.warn.base
        addSubview(lock)
        lock.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
