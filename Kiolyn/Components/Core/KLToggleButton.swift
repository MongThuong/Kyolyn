//
//  KLToggleButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/9/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

class KLToggleButton: FlatButton {
    let disposeBag = DisposeBag()
    var theme: Theme!

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { 
                self.backgroundColor = self.isSelected ? self.theme.primary.lighten3 : .clear
                self.sendActions(for: .valueChanged)
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.smallIconButtonWidth, height: theme.smallIconButtonWidth)
    }
    
    override func prepare() {
        super.prepare()
        layer.cornerRadius = theme.smallIconButtonWidth / 2
        clipsToBounds = true
        rx.tap.map { !self.isSelected }
            .bind(to: rx.isSelected)
            .disposed(by: disposeBag)
    }
}
