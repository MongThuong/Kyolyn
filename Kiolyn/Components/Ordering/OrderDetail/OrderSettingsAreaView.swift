//
//  OrderSettingsAreaView.swift
//  Kiolyn
//
//  Created by Anh Tai LE on 18/08/2018.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Material
import MaterialComponents.MaterialSlider
import SwiftyUserDefaults

class OrderSettingsAreaView: KLView {
    private var viewModel: OrderDetailViewModel!
    private let theme = Theme.mainTheme
    private let disposeBag = DisposeBag()
    
    let scalingTitle = UILabel()
    let scalingSlider = MDCSlider(frame: CGRect(x: 50, y: 50, width: 100, height: 30))
    let subButton = Material.FlatButton()
    let plusButton = Material.FlatButton()
    let resetButton = KLWarnRaisedButton()
    var firstScale: CFloat = 1.0
    // Will scale from 0.25 to 2.0
    let minScale: CGFloat = 0.25
    let maxScale: CGFloat = 2.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

    override func prepare() {
        super.prepare()
        
        // scaling title
        scalingTitle.text = "Scaling"
        scalingTitle.font = theme.normalFont
        scalingTitle.textColor = theme.secondary.base
        self.addSubview(scalingTitle)
        scalingTitle.snp.makeConstraints { make in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(20)
            make.height.equalTo(35)
        }
        
        // add sub button
        subButton.titleColor = UIColor.white
        subButton.titleLabel?.font = theme.titleFont
        subButton.title = "-"
        self.addSubview(subButton)
        subButton.snp.makeConstraints { make in
            make.top.equalTo(scalingTitle).offset(35)
            make.left.equalTo(self).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(20)
        }
        
        // add sub button
        plusButton.titleColor = UIColor.white
        plusButton.titleLabel?.font = theme.titleFont
        plusButton.title = "+"
        self.addSubview(plusButton)
        plusButton.snp.makeConstraints { make in
            make.top.equalTo(scalingTitle).offset(35)
            make.right.equalTo(self).offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(20)
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
            make.top.equalTo(scalingTitle).offset(25)
            make.left.equalTo(subButton).offset(30)
            make.right.equalTo(plusButton).offset(-30)
            make.height.equalTo(45)
        }
        // slider action
        scalingSlider.rx
        .controlEvent(.valueChanged)
        .map { _ in self.scalingSlider.value * (self.maxScale - self.minScale) + self.minScale }
        .subscribe(onNext: { ratio in
            self.viewModel.layoutScale.accept(ratio)
            self.resetButton.isEnabled = abs(ratio - CGFloat(self.firstScale)) >= 0.01
            Defaults[UserDefaults.lastSettingsAreaScale] = Int(ratio * CGFloat(1000))
        }).disposed(by: disposeBag)
        
        // set button
        resetButton.title = "RESET"
        self.addSubview(resetButton)
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-10)
            make.centerX.equalTo(self)
            make.height.equalTo(45)
            make.width.equalTo(160)
        }
        resetButton.rx.tap
        .subscribe(onNext: { _ in
            self.scalingSlider.value = (CGFloat(self.firstScale) - self.minScale) / (self.maxScale - self.minScale)
            self.viewModel.layoutScale.accept(CGFloat(self.firstScale))
            self.resetButton.isEnabled = false
        }).disposed(by: disposeBag)
    }
    
    func updateScaleContent() {
        if Defaults[UserDefaults.lastSettingsAreaScale] == 0 {
            firstScale = 1.0
        } else {
            firstScale = Float(Defaults[UserDefaults.lastSettingsAreaScale]) / Float(1000)
        }
        viewModel.layoutScale.accept(CGFloat(firstScale))
        resetButton.isEnabled = false
    }
}
