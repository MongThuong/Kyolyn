//
//  KLMenuView.swift
//  Kiolyn
//
//  Created by Anh Tai LE on 17/08/2018.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Material
import SwiftyUserDefaults

class KLMenuView: View, UIScrollViewDelegate {

    let minItemsToKeepOffset: Int = 4
    let minScaleValue: CGFloat = 0.25
    let maxScaleValue: CGFloat = 2.0
    let itemsView = UIScrollView()
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)
    var settings: OrderingGridSettings!
    var viewModel: KLMenuViewModel!

    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        
        // call to setup settings
        allocSettinggs()
        
        // setup ui
        itemsView.contentSize = CGSize(width: settings.totalWidth, height: settings.totalHeight)
        itemsView.delegate = self
        itemsView.isDirectionalLockEnabled = true
        itemsView.maximumZoomScale = maxScaleValue
        itemsView.minimumZoomScale = minScaleValue
        addSubview(itemsView)
        
        // remove UIPinchGesture
        if let _: UIPinchGestureRecognizer = itemsView.pinchGestureRecognizer {
            itemsView.removeGestureRecognizer(itemsView.pinchGestureRecognizer!)
        }
        
        // Handle zoom content view
        itemsView.zoomScale = 1.0 // reset in the first time
        layoutScale.subscribe(onNext: { ratio in
            self.settings.scale = ratio
            self.itemsView.zoomScale = 1.0
            self.itemsView.setZoomScale(ratio, animated: false)
        }).disposed(by: disposeBag)
    }
    
    func allocSettinggs() {
        // require to setup
    }
    
    // need override to calculate content offset
    func itemsInView() -> Int {
        return 0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: itemsInView() > minItemsToKeepOffset ? scrollView.contentOffset.x : 0 , y: 0)
        scrollView.contentSize = CGSize(width: settings.totalWidth, height: settings.totalHeight)
    }
    
    func getFirstScale() -> CGFloat {
        var scale: Float = 0
        if Defaults[UserDefaults.lastSettingsAreaScale] == 0 {
            scale = 1
        } else {
            scale = Float(Defaults[UserDefaults.lastSettingsAreaScale]) / Float(1000)
        }
        return CGFloat(scale)
    }
}
