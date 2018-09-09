//
//  RestEmailService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/5/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class RestEmailService: EmailService {
    
    /// Send email by calling backend API, errors are logged and ignored
    ///
    /// - Parameters:
    ///   - email: to email.
    ///   - body: body content
    ///   - title: title
    /// - Returns: Single of the email sending.
    override func send(email: String, withBody body: String, andTitle title: String) -> Single<()> {
        guard let store = SP.authService.store else {
            return Single.just(())
        }
        return Single.create { single in
            let data: [String: Any] = [
                "to": email,
                "title": title,
                "body": body
            ]
            Alamofire.request("\(Configuration.apiRootURL)/v2/app/email/\(store.id)", method: .post, parameters: data, encoding: JSONEncoding.default)
                .response(completionHandler: { res in
                    if let error = res.error {
                        e(error)
                    }
                    single(.success(()))
                }
            )
            return Disposables.create()
        }
    }
}
