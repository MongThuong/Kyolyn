//
//  Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    // Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
    public func mapToVoid() -> Observable<Void> {
        return self.map { _ -> Void in
            return ()
        }
    }
}
