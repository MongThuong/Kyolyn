//
//  KLCalendarView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/2/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import JTAppleCalendar
import Material
import RxSwift
import RxCocoa
import FontAwesomeKit

class KLCalendarView: KLView {
    let theme =  Theme.mainTheme
    var disposeBag: DisposeBag?
    let rootView = KLView()
    let coverView = KLView()
    let calendar = JTAppleCalendarView()
    let year = UILabel()
    let date = UILabel()
    let header = UIView()
    let monthHeader = UIView()
    let dayOfWeekHeader = UIStackView()
    let monthLabel = UILabel()
    let nextMonth = KLFlatButton()
    let prevMonth = KLFlatButton()
    
    lazy var expectedWidth: CGFloat = { return self.theme.buttonHeight * 7 }()
    let expectedHeight: CGFloat = 400
    var selectedDateOffset: CGPoint?
    
    /// Call this to close the dialog with a given date
    var close: ((_ selectedDate: Date?) -> Void)? = nil
    
    var selectedDate: Date = Date() {
        didSet {
            year.text = selectedDate.toString("yyyy")
            date.text = selectedDate.toString("E, MMM dd")
            
            let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
            currentMonth = DateComponents(calendar: .current, year: components.year, month: components.month, day: 1).date!
        }
    }
    
    var currentMonth: Date = Date() {
        didSet {
            self.monthLabel.text = currentMonth.toString("MMM yyyy")
        }
    }
    
    override func prepare() {
        super.prepare()
        
        guard let parent = UIApplication.shared.keyWindow else {
            return
        }
        // Take full parent frame
        frame = parent.frame
        // Transparent background
        backgroundColor = .clear// UIColor.black.withAlphaComponent(0.75)
        self.alpha = 0
        parent.addSubview(self)
        
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.000001)
        coverView.frame = frame
        addSubview(coverView)
        
        year.font = theme.normalFont
        year.textColor = theme.textColor
        header.addSubview(year)
        year.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(theme.guideline)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy((expectedWidth-theme.guideline*2)/expectedWidth)
        }
        
        date.backgroundColor = .clear
        date.font = theme.titleFont
        date.textColor = theme.textColor
        header.addSubview(date)
        date.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy((expectedWidth-theme.guideline*2)/expectedWidth)
            make.bottom.equalToSuperview().offset(-theme.guideline)
        }
        
        header.backgroundColor = theme.secondary.base
        rootView.addSubview(header)
        header.snp.makeConstraints { make in
            make.width.centerX.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        nextMonth.fakIcon = FAKFontAwesome.angleRightIcon(withSize: 16)
        prevMonth.fakIcon = FAKFontAwesome.angleLeftIcon(withSize: 16)
        monthHeader.addSubview(nextMonth)
        monthHeader.addSubview(prevMonth)
        nextMonth.snp.makeConstraints { make in
            make.centerY.height.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(theme.buttonHeight/expectedWidth)
        }
        prevMonth.snp.makeConstraints { make in
            make.centerY.height.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(theme.buttonHeight/expectedWidth)
        }
        
        monthLabel.font = theme.normalBoldFont
        monthLabel.textColor = theme.textColor
        monthLabel.textAlignment = .center
        monthHeader.addSubview(monthLabel)
        monthLabel.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.leading.equalTo(prevMonth.snp.trailing)
            make.trailing.equalTo(nextMonth.snp.leading)
        }
        
        monthHeader.alpha = 0.75
        rootView.addSubview(monthHeader)
        monthHeader.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(theme.buttonHeight/expectedHeight)
        }
        
        dayOfWeekHeader.axis = .horizontal
        dayOfWeekHeader.alignment = .center
        dayOfWeekHeader.distribution = .fillEqually
        for v in dayOfWeekHeader.arrangedSubviews {
            dayOfWeekHeader.removeArrangedSubview(v)
        }
        for d in ["S", "M", "T", "W", "T", "F", "S"] {
            let label = UILabel()
            label.font = theme.smallBoldFont
            label.text = d
            label.textColor = theme.textColor
            label.textAlignment = .center
            label.alpha = 0.75
            dayOfWeekHeader.addArrangedSubview(label)
        }
        rootView.addSubview(dayOfWeekHeader)
        dayOfWeekHeader.snp.makeConstraints { make in
            make.top.equalTo(monthHeader.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(theme.textSmallHeight/expectedHeight)
        }
        
        calendar.minimumInteritemSpacing = 0
        calendar.minimumLineSpacing = 0
        calendar.allowsDateCellStretching = true
        calendar.backgroundColor = .clear
        calendar.scrollDirection = .horizontal
        calendar.calendarDataSource = self
        calendar.calendarDelegate = self
        calendar.register(KLDayCell.self, forCellWithReuseIdentifier: "Cell")
        rootView.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.top.equalTo(dayOfWeekHeader.snp.bottom)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        rootView.clipsToBounds = true
        rootView.backgroundColor = theme.primary.darken4
        rootView.depthPreset = .depth1
        rootView.cornerRadiusPreset = .cornerRadius1
        rootView.layoutSubviews()
        addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.width.equalTo(self.expectedWidth)
            make.height.equalTo(self.expectedHeight)
        }
        
        // To prevent multiple call (dispose old link by assigning a new one)
        disposeBag = DisposeBag()
        // Update initially
        nextMonth.rx.tap
            .subscribe(onNext: { self.calendar.scrollToSegment(.next) })
            .disposed(by: disposeBag!)
        prevMonth.rx.tap
            .subscribe(onNext: { self.calendar.scrollToSegment(.previous) })
            .disposed(by: disposeBag!)
    }
    
    /// Setup calendar to generate visibleCells mapping with month
    ///
    /// - Parameters:
    ///   - date: inital date of calendar
    /// - Returns: void
    func setup(_ date: Date) {
        selectedDate = date
        calendar.selectDates([selectedDate], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
        calendar.scrollToDate(selectedDate, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0) {
            self.selectedDateOffset = self.calendar.contentOffset
        }
        
    }
    
    /// Show the dialog with support for closed callback
    ///
    /// - Parameters:
    ///   - parent: The view to show dialog upon.
    ///   - onClosed: The closed callback with a result.
    /// - Returns: The dialog itself
    func show(anchored view: UIView, date: Date = Date()) -> Single<Date?> {
        guard let parent = UIApplication.shared.keyWindow else {
            return Single.just(nil)
        }
        
        return Single.create { single -> Disposable in
            
            self.selectedDate = date
            
            let frame = view.convert(view.frame, to: parent)
            self.rootView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(frame.origin.y + frame.size.height + 4)
                make.left.equalToSuperview().offset(view.frame.origin.x + 8)
            }
            
            self.close = { selectedDate in
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.rootView.frame = CGRect.init(x: self.rootView.frame.origin.x, y: self.rootView.frame.origin.y, width: 0, height: 0)
                }, completion: { _ in
                    self.close = nil
                    
                    // Save selected date's offset
                    if let _ = selectedDate {
                        self.selectedDateOffset = self.calendar.contentOffset
                    }
                    
                    // Complete the date popup
                    single(.success(selectedDate))
                })
            }
            // Tap on background to close
            let bgTapDisposable = self.coverView.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { _ in self.close?(nil) })
            
            // Animate the root view in
            let rframe = self.rootView.frame
            let x = rframe.origin.x
            let y = rframe.origin.y + rframe.size.height
            self.rootView.frame = CGRect.init(x: x, y: y, width: 0, height: 0)
            self.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
                self.rootView.frame = CGRect.init(x: x, y: y, width: self.expectedWidth, height: self.expectedHeight)
            }, completion: { _ in
                // scroll to previous of selected date's offset
                if let offset = self.selectedDateOffset {
                    self.calendar.contentOffset = offset
                }
            })
            return Disposables.create([bgTapDisposable])
        }
    }
}

extension KLCalendarView: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startDate = DateComponents(calendar: .current, year: currentYear-1, month: 1, day: 1)
        return ConfigurationParameters(startDate: startDate.date!, endDate: Date(), numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid,                                              firstDayOfWeek: .sunday, hasStrictBoundaries: true)
    }
}

extension KLCalendarView: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KLDayCell
        cell.title.text = cellState.text
        cell.isSelected = cellState.isSelected
        cell.isHidden = cellState.dateBelongsTo != .thisMonth
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.currentMonth = visibleDates.monthDates.first!.date
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        self.close?(date)
    }
}

fileprivate class KLDayCell: JTAppleCell {
    let theme = Theme.mainTheme
    let title = UILabel()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = theme.buttonHeight/2
        
        title.font = theme.normalFont
        title.textColor = theme.textColor
        title.textAlignment = .center
        addSubview(title)
        title.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? theme.secondary.base : .clear
            title.font = isSelected ? theme.normalBoldFont : theme.normalFont
        }
    }
}
