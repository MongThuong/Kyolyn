//
//  OrderItemsSummary.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// Order summary including subtotal, tax, total.
class OrderItemsSummary: KLView  {
    private let theme =  Theme.mainTheme
    
    let container = UIStackView()
    let subtotal = NameValueView.name("Subtotal")
    let discount = NameValueView.name("Discount")
    let tax = NameValueView.name("Tax")
    let serviceFee = NameValueView.name("Group Gratuity")
    let serviceFeeTax = NameValueView.name("Group Gratuity Tax")
    let customServiceFee = NameValueView.name("Service Fee")
    let total = NameValueView.name("Total")
    let splittedTotal = NameValueView.name("Split Total")
    var rows: [NameValueView]!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        rows = [subtotal, discount, tax, serviceFee, serviceFeeTax, customServiceFee, total, splittedTotal]
        super.init(frame: .zero)
    }
    
    var orderItemsContainer: OrderItemsContainer? {
        didSet {
            defer {
                invalidateIntrinsicContentSize()
            }
            
            guard let container = orderItemsContainer else {
                subtotal.isHidden = true
                discount.isHidden = true
                tax.isHidden = true
                serviceFee.isHidden = true
                serviceFeeTax.isHidden = true
                customServiceFee.isHidden = true
                splittedTotal.isHidden = true
                total.isHidden = true
                return
            }
            
            subtotal.amount.text = container.subtotal.asMoney
            
            discount.name.text = "\(container.discount.name) (\(container.discount.adjustedPercent > 0 ? container.discount.adjustedPercent.asPercentage : container.discount.percent.asPercentage))"
            discount.isHidden = container.discountAmount == 0
            discount.amount.text = container.discountAmount.asMoney
            
            tax.name.text = "\(container.tax.name) (\(container.tax.percent.asPercentage))"
            tax.amount.text = container.taxAmount.asMoney
            
            serviceFee.name.text = "Group Gratuity (\(container.serviceFee.asPercentage))"
            serviceFee.amount.text = container.serviceFeeAmount.asMoney
            serviceFee.isHidden = container.serviceFeeAmount == 0
            
            serviceFeeTax.name.text = "Group Gratuity Tax (\(container.serviceFeeTax.asPercentage))"
            serviceFeeTax.amount.text = container.serviceFeeTaxAmount.asMoney
            serviceFeeTax.isHidden = container.serviceFeeTaxAmount == 0
            
            if container.customServiceFeePercent > 0 {
                customServiceFee.name.text = "Service Fee (\(container.customServiceFeePercent.asPercentage))"
            } else {
                customServiceFee.name.text = "Service Fee"
            }
            customServiceFee.amount.text = container.customServiceFeeAmount.asMoney
            customServiceFee.isHidden = container.customServiceFeeAmount == 0
            
            splittedTotal.name.textColor = theme.warn.base
            splittedTotal.amount.textColor = theme.warn.base
            splittedTotal.isHidden = true
            
            total.amount.text = container.total.asMoney
            
            if container is Bill {
                let bill: Bill = container as! Bill
                if bill.isSplitted {
                    total.amount.text = bill.parentTotal.asMoney
                    splittedTotal.amount.text = bill.total.asMoney
                    splittedTotal.isHidden = false
                }
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let height = rows.reduce(0.0) { (h, row) -> CGFloat in
            guard !row.isHidden else { return h }
            row.name.sizeToFit()
            return h + row.name.frame.height + theme.guideline/2
        }
        return CGSize(width: size.width, height: height)
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        total.font = theme.heading3BoldFont
        splittedTotal.font = theme.heading3BoldFont
        
        container.axis = .vertical;
        container.distribution = .fill
        container.alignment = .fill
        container.spacing = theme.guideline/2
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline/2)
        }
        for row in rows {
            container.addArrangedSubview(row)
        }
    }
}
