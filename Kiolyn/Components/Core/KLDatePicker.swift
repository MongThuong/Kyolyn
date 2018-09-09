//
//  KLDateButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/2/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa
import FontAwesomeKit

class KLDatePicker : FlatButton {
    private let disposeBag = DisposeBag()
    private var theme: Theme!
    
    private let border = CALayer()
    private let value = UILabel()
    private let icon = UILabel()
    private let calendar = KLCalendarView()
    private let content = UIStackView()
    
    /// Custom the dropdown with
    var calendarSize: CGSize = CGSize(width: 400, height: 440)
    
    /// Hold the date value
    var date: Date = Date() {
        didSet {
            value.text = date.toString("MM/dd/yyyy")
            sendActions(for: .valueChanged)
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: value.intrinsicContentSize.width + icon.intrinsicContentSize.width + theme.guideline + contentEdgeInsets.left + contentEdgeInsets.right, height: super.intrinsicContentSize.height)
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
        
        backgroundColor = .clear
        border.backgroundColor = theme.dividersColor.cgColor
        layer.addSublayer(border)
        
        content.axis = .horizontal
        content.distribution = .fill
        content.alignment = .fill
        content.isUserInteractionEnabled = false
        addSubview(content)
        
        value.font = theme.normalFont
        value.textColor = theme.secondaryTextColor
        value.isUserInteractionEnabled = false
        content.addArrangedSubview(value)
        
        icon.contentMode = .scaleAspectFit
        icon.textColor = theme.secondaryTextColor
        icon.fakIcon = FAKFontAwesome.calendarIcon(withSize: 16)
        icon.isUserInteractionEnabled = false
        content.addArrangedSubview(icon)
        
        date = Date()
        
        // set initial date for calendar
        calendar.setup(date)
        
        rx.tap
            .flatMap { _ in self.calendar.show(anchored: self, date: self.date) }
            .filterNil()
            .subscribe(onNext: { date in self.date = date })
            .disposed(by: disposeBag)
        // Close on logout
        SP.authService.currentIdentity
            .filter { $0 == nil }
            .subscribe(onNext: { _ in self.calendar.close?(nil) })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: 0, y: frame.height-1, width: frame.width, height: 1)
        content.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height-1)
        content.spacing = theme.guideline
    }
}

extension Reactive where Base: KLDatePicker {
    /// Reactive wrapper for `text` property.
    var date: ControlProperty<Date> {
        return base.rx.controlProperty(
            editingEvents: [.valueChanged],
            getter: { $0.date },
            setter: { field, value in field.date = value }
        )
    }
}

