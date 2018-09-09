//
//  TablesLayoutScalingView.swift
//  Kiolyn
//
//  Created by Anh Tai LE on 25/08/2018.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import Material
import MaterialComponents.MaterialSlider
import SwiftyUserDefaults

extension Reactive where Base: TablesLayoutScalingView {
    /// Reactive wrapper for `text` property.
    var scaleValue: ControlProperty<CGFloat> {
        return base.rx.controlProperty(
            editingEvents: [.allEditingEvents, .valueChanged],
            getter: { field in field.value },
            setter: { field, value in field.value = value }
        )
    }
}

class TablesLayoutScalingView: UIControl {

    private let theme = Theme.mainTheme
    private let disposeBag = DisposeBag()
    
    let scalingTitle = UILabel()
    let scalingSlider = MDCSlider(frame: CGRect(x: 50, y: 50, width: 100, height: 30))
    let subButton = Material.FlatButton()
    let plusButton = Material.FlatButton()
    
    // Will scale from 0.25 to 2.0
    var firstScale: CFloat = 1.0
    let minScale: CGFloat = 0.25
    let maxScale: CGFloat = 2.0
    
    var value: CGFloat = 1.0 {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        prepare()
    }

    func prepare() {
        
        self.backgroundColor = UIColor.clear
        
        // scaling title
        scalingTitle.text = "Scaling"
        scalingTitle.font = theme.heading1Font
        scalingTitle.textColor = theme.secondary.base
        self.addSubview(scalingTitle)
        scalingTitle.snp.makeConstraints { make in
            make.top.equalTo(self).offset(theme.guideline/2)
            make.left.equalTo(self).offset(theme.guideline * 2)
            make.height.equalTo(theme.guideline * 7)
        }
        
        // add sub button
        subButton.titleColor = UIColor.white
        subButton.titleLabel?.font = theme.titleFont
        subButton.title = "-"
        self.addSubview(subButton)
        subButton.snp.makeConstraints { make in
            make.top.equalTo(scalingTitle).offset(theme.guideline * 2)
            make.left.equalTo(scalingTitle).offset(theme.guideline * 14)
            make.width.equalTo(theme.guideline * 4)
            make.height.equalTo(theme.guideline * 3)
        }
        
        // add sub button
        plusButton.titleColor = UIColor.white
        plusButton.titleLabel?.font = theme.titleFont
        plusButton.title = "+"
        self.addSubview(plusButton)
        plusButton.snp.makeConstraints { make in
            make.top.equalTo(scalingTitle).offset(theme.guideline * 2)
            make.right.equalTo(self).offset(-theme.guideline * 7)
            make.width.equalTo(theme.guideline * 4)
            make.height.equalTo(theme.guideline * 3)
        }
        
        // scaling slider
        updateScaleContent()
        self.addSubview(scalingSlider)
        scalingSlider.isStatefulAPIEnabled = true
        scalingSlider.value = (CGFloat(firstScale) - minScale) / (maxScale - minScale)
        scalingSlider.setTrackFillColor(.white, for: .normal)
        scalingSlider.setFilledTrackTickColor(.white, for: .normal)
        scalingSlider.setThumbColor(.white, for: .selected)
        scalingSlider.setThumbColor(.white, for: .normal)
        scalingSlider.snp.makeConstraints { make in
            make.top.equalTo(scalingTitle).offset(theme.guideline)
            make.left.equalTo(subButton).offset(theme.guideline * 4)
            make.right.equalTo(plusButton).offset(-theme.guideline * 5)
            make.height.equalTo(theme.guideline * 5)
        }
        // slider action
        scalingSlider.rx
            .controlEvent(.valueChanged)
            .map { _ in self.scalingSlider.value * (self.maxScale - self.minScale) + self.minScale }
            .subscribe(onNext: { ratio in
                Defaults[UserDefaults.lastTablesLayoutScale] = Int(ratio * CGFloat(1000))
                self.value = ratio
            }).disposed(by: disposeBag)
    }
    
    func updateScaleContent() {
        if Defaults[UserDefaults.lastTablesLayoutScale] == 0 {
            firstScale = 1.0
        } else {
            firstScale = Float(Defaults[UserDefaults.lastTablesLayoutScale]) / Float(1000)
        }
        self.value = CGFloat(firstScale)
    }
    
}
