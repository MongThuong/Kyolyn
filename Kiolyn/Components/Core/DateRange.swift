//
//  DateRange.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// The list of available date ranges for displaying in fitler.
enum DateRange {
    case custom
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case thisQuarter
    case lastQuarter
    case thisYear
    case lastYear
    
    static var all: [DateRange] {
        return [.today, .yesterday, .thisWeek, .lastWeek, .thisMonth, .lastMonth, .thisQuarter, .lastQuarter, .thisYear, .lastYear, .custom]
    }
    
    var displayName: String {
        switch self {
        case .custom: return "CUSTOM"
        case .today: return "TODAY"
        case .yesterday: return "YESTERDAY"
        case .thisWeek: return "THIS WEEK"
        case .lastWeek: return "LAST WEEK"
        case .thisMonth: return "THIS MONTH"
        case .lastMonth: return "LAST MONTH"
        case .thisQuarter: return "THIS QUARTER"
        case .lastQuarter: return "LAST QUARTER"
        case .thisYear: return "THIS YEAR"
        case .lastYear: return "LAST YEAR"
        }
    }
    
    var dateRange: (Date, Date)? {
        let today = Date()
        let cal = Calendar.current
        switch self {
        case .custom: return nil
        case .today: return (today, today)
        case .yesterday:
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: today) else { return nil }
            return (yesterday, yesterday)
        case .thisWeek:
            guard let sunday = cal.date(bySetting: .weekday, value: 1, of: today), let fdate = cal.date(byAdding: .day, value: -7, to: sunday) else { return nil }
            return (fdate, today)
        case .lastWeek:
            guard let sunday = cal.date(bySetting: .weekday, value: 1, of: today), let fdate = cal.date(byAdding: .day, value: -14, to: sunday), let tdate = cal.date(byAdding: .day, value: -8, to: sunday) else { return nil }
            return (fdate, tdate)
        case .thisMonth:
            var components = cal.dateComponents([.year, .month], from: today)
            components.day = 1
            guard let fdate = cal.date(from: components) else { return nil }
            return (fdate, today)
        case .lastMonth:
            var components = cal.dateComponents([.year, .month], from: today)
            components.day = 1
            guard let firstDayOfMonth = cal.date(from: components), let fdate = cal.date(byAdding: .month, value: -1, to: firstDayOfMonth), let tdate = cal.date(byAdding: .day, value: -1, to: firstDayOfMonth) else { return nil }
            return (fdate, tdate)
        case .thisQuarter:
            var components = cal.dateComponents([.year, .month], from: today)
            components.day = 1
            components.month = components.month!/3 * 3 + 1
            guard let fdate = cal.date(from: components) else { return nil }
            return (fdate, today)
        case .lastQuarter:
            var components = cal.dateComponents([.year, .month], from: today)
            components.day = 1
            components.month = components.month!/3 * 3 + 1
            guard let firstDayOfQuarter = cal.date(from: components), let fdate = cal.date(byAdding: .month, value: -3, to: firstDayOfQuarter), let tdate = cal.date(byAdding: .day, value: -1, to: firstDayOfQuarter) else { return nil }
            return (fdate, tdate)
        case .thisYear:
            var components = cal.dateComponents([.year], from: today)
            components.day = 1
            components.month = 1
            guard let fdate = cal.date(from: components) else { return nil }
            return (fdate, today)
        case .lastYear:
            var components = cal.dateComponents([.year], from: today)
            components.day = 1
            components.month = 1
            guard let firstDayOfYear = cal.date(from: components), let fdate = cal.date(byAdding: .year, value: -1, to: firstDayOfYear), let tdate = cal.date(byAdding: .day, value: -1, to: firstDayOfYear) else { return nil }
            return (fdate, tdate)
        }
    }
}
