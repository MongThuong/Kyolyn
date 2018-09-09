//
//  TablesView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa
import SwiftyUserDefaults

/// For displaying Tables Layout
class TablesView: KLView, UIScrollViewDelegate {
    fileprivate let theme =  Theme.mainTheme
    fileprivate let disposeBag = DisposeBag()
    fileprivate let dashPattern : [CGFloat] = [4, 2]

    fileprivate let layoutView = UIScrollView()

    let area = BehaviorRelay<AreaViewModel?>(value: nil)
    let selectTable = PublishSubject<TableViewModel>()
    let selectCustomer = PublishSubject<Order>()
    let selectDriver = PublishSubject<Order>()
    let selectDelivered = PublishSubject<Order>()
    var layoutScalingView: TablesLayoutScalingView!

    // Scale area
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)
    let minScaleValue: CGFloat = 0.25
    let maxScaleValue: CGFloat = 2.0
    let minItemsToKeepOffset: Int = 6
    var haveScalingLayout: Bool = false
    var tableContentSize: CGSize!
    
    init(_ havingScale: Bool) {
        self.haveScalingLayout = havingScale
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func tableButton() -> TableButton {
        // Find an available one
        if let atb = layoutView.subviews.first!.subviews.first(where: { v in
            guard let tb = v as? TableButton else { return false }
            return tb.table == nil
        }) {
            return atb as! TableButton
        }
        // Or create new one
        let atb = TableButton()
        layoutView.subviews.first!.addSubview(atb)
        return atb
    }

    fileprivate func orderButton(type: OrderButtonType) -> OrderButton {
        // Find an available one
        if let aob = layoutView.subviews.first!.subviews.first(where: { v in
            guard let ob = v as? OrderButton, ob.type == type else { return false }
            return ob.order == nil
        }) {
            return aob as! OrderButton            
        }
        // Or create new one
        let aob = OrderButton()
        aob.type = type
        layoutView.subviews.first!.addSubview(aob)
        return aob
    }

    fileprivate func hideAll() {
        for v in layoutView.subviews.first!.subviews {
            v.isHidden = true
            if let tb = v as? TableButton {
                tb.disposeBag = nil
                tb.table = nil
                tb.isSelected = false
                tb.isEnabled = false
            } else if let ob = v as? OrderButton {
                ob.disposeBag = nil
                ob.order = nil
            }
        }
    }

    fileprivate func set(tables: [TableViewModel]) {
        // Hide all buttons first
        hideAll()
        guard let area = area.value else { return }
        let tw = layoutView.frame.size.width
        let gl = theme.guideline/2

        if area.area.isAutoIncrement {
            layoutView.contentSize = CGSize(width: tw, height: CGFloat(tables.count * 84))
        } else {
            layoutView.contentSize = theme.tablesViewSize
        }
        
        // save the content size
        tableContentSize = CGSize(width: layoutView.contentSize.width, height: layoutView.contentSize.height)

        // create a content view
        for view in layoutView.subviews {
            view.removeFromSuperview()
        }
        let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableContentSize.width, height: tableContentSize.height))
        contentView.backgroundColor = UIColor.clear
        layoutView.addSubview(contentView)
        
        // Assign table to buttons (create if necessary)
        for table in tables {
            let tb = self.tableButton()
            tb.disposeBag = DisposeBag()
            tb.rx.tap.map { table }.bind(to: selectTable).disposed(by: tb.disposeBag!)
            tb.table = table
            // Auto increment specific
            guard area.area.isAutoIncrement, let order = table.orders.value.first else {
                continue
            }

            let cb = orderButton(type: .customer)
            cb.isHidden = false
            cb.order = order
            cb.disposeBag = DisposeBag()
            cb.rx.tap.map { order }.bind(to: selectCustomer).disposed(by: cb.disposeBag!)
            table.tableState
                .map { state in
                    let (orders, lockedOrders, _, selectedOrder) = state
                    if selectedOrder != nil { return false }
                    guard let order = orders.first else { return false }
                    return order.notDelivered && lockedOrders.isNotLocked(order)
                }
                .drive(cb.rx.isEnabled)
                .disposed(by: cb.disposeBag!)
            

            let tbf = tb.frame
            let cx = tbf.origin.x + tbf.width + gl
            let oy = tbf.origin.y + gl
            let oh = tbf.height - gl * 2

            if area.area.isToGo {
                cb.frame = CGRect(x: cx, y: oy, width: tw - cx - gl, height: oh)
            } else {
                let drw: CGFloat = 120
                let dlw: CGFloat = 120

                cb.frame = CGRect(x: cx, y: oy, width: tw - cx - drw - dlw - gl * 3, height: oh)

                let drb = orderButton(type: .driver)
                drb.frame = CGRect(x: cb.frame.origin.x + cb.frame.size.width + gl, y: oy, width: drw, height: oh)
                drb.isHidden = false
                drb.order = order
                drb.disposeBag = DisposeBag()
                drb.rx.tap.map { order }.bind(to: selectDriver).disposed(by: drb.disposeBag!)
                table.tableState
                    .map { state in
                        let (orders, lockedOrders, _, selectedOrder) = state
                        if selectedOrder != nil { return false }
                        guard let order = orders.first else { return false }
                        return order.notDelivered && !lockedOrders.keys.contains(order.id)
                    }
                    .drive(drb.rx.isEnabled)
                    .disposed(by: drb.disposeBag!)

                let dlb = orderButton(type: .delivered)
                dlb.frame = CGRect(x: drb.frame.origin.x + drb.frame.size.width + gl, y: oy, width: dlw, height: oh)
                dlb.isHidden = false
                dlb.order = order
                dlb.disposeBag = DisposeBag()
                dlb.rx.tap.map { order }.bind(to: selectDelivered).disposed(by: dlb.disposeBag!)
                table.tableState
                    .map { state in
                        let (orders, lockedOrders, _, selectedOrder) = state
                        if selectedOrder != nil { return false }
                        guard let order = orders.first else { return false }
                        return order.notDelivered && order.isChecked && lockedOrders.isNotLocked(order)
                    }
                    .drive(dlb.rx.isEnabled)
                    .disposed(by: dlb.disposeBag!)
            }
        }
        
        // set zoom level
        if area.area.isNotAutoIncrement && haveScalingLayout {
            layoutView.setZoomScale(getFirstScale(), animated: false)
            layoutView.contentOffset = CGPoint(x: 0, y: 0)
            
            // handle show layoutScalingView
            if self.layoutScalingView != nil {
                self.layoutScalingView.isHidden = false
                
                // update constrant
                layoutView.snp.updateConstraints { make in
                    make.top.equalTo(self).offset(0)
                    make.left.equalTo(self).offset(0)
                    make.bottom.equalTo(self).offset(-theme.guideline * 10)
                }
            }
            
            
        } else {
            layoutView.setZoomScale(1.0, animated: false)
            layoutView.contentSize = CGSize(width: tableContentSize.width, height: tableContentSize.height)
            layoutView.contentOffset = CGPoint(x: 0, y: 0)
            
            // handle show layoutScalingView
            if layoutScalingView != nil {
                layoutScalingView.isHidden = true
                
                // update constraint
                layoutView.snp.updateConstraints { make in
                    make.top.equalTo(self).offset(0)
                    make.left.equalTo(self).offset(0)
                    make.bottom.equalTo(self).offset(0)
                }
            }
        }
    }

    /// Prepare the view
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        layoutView.backgroundColor = .clear
        layoutView.showsVerticalScrollIndicator = true
        layoutView.showsHorizontalScrollIndicator = true
        layoutView.contentSize = theme.tablesViewSize
        layoutView.clipsToBounds = true
        addSubview(layoutView)
        layoutView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        area.asDriver()
            .filterNil()
            .flatMapLatest { $0.tables.asDriver() }
            .drive(onNext: { self.set(tables: $0) })
            .disposed(by: disposeBag)
        
        // set scale layout
        layoutView.zoomScale = 1.0
        tableContentSize = layoutView.contentSize
        
        // handle check to create scaling area
        if haveScalingLayout {
            layoutScalingView = TablesLayoutScalingView()
            self.addSubview(layoutScalingView)
            
            // set zoomable
            layoutView.delegate = self
            layoutView.isDirectionalLockEnabled = true
            layoutView.maximumZoomScale = maxScaleValue
            layoutView.minimumZoomScale = minScaleValue
            
            // remove UIPinchGesture
            if let _: UIPinchGestureRecognizer = layoutView.pinchGestureRecognizer {
                layoutView.removeGestureRecognizer(layoutView.pinchGestureRecognizer!)
            }
            
            // update frame of scaling view
            layoutScalingView.snp.makeConstraints { make in
                make.bottom.equalTo(self).offset(-theme.guideline * 2)
                make.left.equalTo(self).offset(theme.guideline)
                make.right.equalTo(self).offset(theme.guideline)
                make.height.equalTo(theme.guideline * 8)
            }
            
            // update frame of scrollview
            layoutView.snp.updateConstraints { make in
                make.top.equalTo(self).offset(0)
                make.left.equalTo(self).offset(0)
                make.bottom.equalTo(self).offset(-theme.guideline * 10)
            }
            
            // handle set scale
            layoutScalingView.rx.scaleValue
            .asDriver()
            .drive(layoutScale)
            .disposed(by: disposeBag)
            
            // handle for scale
            layoutScale.subscribe(onNext: { ratio in
                self.layoutView.setZoomScale(ratio, animated: false)
                self.layoutView.contentSize = CGSize(width: self.tableContentSize.width * ratio, height: self.tableContentSize.height * ratio)
            }).disposed(by: disposeBag)
        }
    }

    /// Override for drawing the dashed border around the content.
    ///
    /// - Parameter rect: The drawing rect.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        // Transaparent background
        UIColor.clear.setFill()
        path.fill()
        // White border
        UIColor.white.setStroke()
        path.lineWidth = 2
        path.setLineDash(dashPattern, count: 2, phase: 0)
        path.stroke()
        // Draw the main content
        super.draw(rect)
    }
    
    func getFirstScale() -> CGFloat {
        var scale: Float = 0
        if Defaults[UserDefaults.lastTablesLayoutScale] == 0 {
            scale = 1
        } else {
            scale = Float(Defaults[UserDefaults.lastTablesLayoutScale]) / Float(1000)
        }
        return CGFloat(scale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: scrollView.subviews.first!.subviews.count > minItemsToKeepOffset ? scrollView.contentOffset.x : 0 , y: 0)
    }
}

