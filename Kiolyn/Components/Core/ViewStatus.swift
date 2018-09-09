//
//  ViewStatus.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

/// Represent the status of a view.
///
/// - loading: Should show a loading progress indicator some where.
/// - error: Should show error.
/// - ok: Should show success.
enum ViewStatus: Equatable {
    case none
    case loading
    case progress(p: Double)
    case message(m: String)
    case error(reason: String)
    case ok
    
    var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .message(_):
            return true
        case let .progress(p):
            return p < 1.0
        default:
            return false
        }
    }
    var isNotLoading: Bool { return !isLoading }
    
    var isError: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
    var isNotError: Bool { return !isError }
    
    var isOK: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    var isNotOK: Bool { return !isOK }
    
    var progress: Double {
        switch self {
        case .progress(let p):
            return p
        default:
            return 0.0
        }
    }
    
    var errorMessage: String {
        switch self {
        case .error(let message):
            return message
        default:
            return ""
        }
    }
    
    public static func ==(a:ViewStatus, b:ViewStatus) -> Bool {
        return (a.isNone && b.isNone) || (a.isLoading && b.isLoading) || (a.isOK && b.isOK)
            || (a.isError && b.isError && a.errorMessage == b.errorMessage)
    }
}


