//
//  Store.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Store` in system, this `Store` is not meant to be updated but getting from a Sync Session API call.
class Store: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "store" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "store" }
    
    /// Name of Store.
    var storeName = ""
    /// This is a non-meta value for storing a Merchant ID (this ID is barely data).
    var storeMerchantID = ""
    /// Meta information
    var terminalID = ""
    /// Business address of this Store.
    var bizAddress = ""
    /// Business city of this Store
    var bizCity = ""
    /// Business state fo this Store.
    var bizState = ""
    /// Business zip of this Store.
    var bizZip = ""
    /// Business email of this Store.
    var bizEmail: String = ""
    /// Business email of this Store.
    var email: String = ""
    /// Business phone of this Store
    var bizPhone = ""
    /// Business owner first name.
    var firstName = ""
    /// Business owner last name.
    var lastName = ""
    /// The sync session of this Store.
    var syncSession: SyncSession? = nil
    /// Logo of store
    var logo: Image?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        storeName <- map["store_name"]
        storeMerchantID <- map["merchant_id"]
        terminalID <- map["terminal_id"]
        bizAddress <- map["biz_address"]
        bizCity <- map["biz_city"]
        bizState <- map["biz_state"]
        bizZip <- map["biz_zip"]
        bizEmail <- map["biz_email"]
        email <- map["email"]
        bizPhone <- map["biz_phone"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        syncSession <- map["sync_session"]
        logo <- map["logo"]
    }
}

/// Expires datetime formatter, we omit the milliseconds because it printed differently across platforms
let syncSessionExpiresFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return df
}()

/// Converting expires date between String and Date
fileprivate let expiresTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
    guard let value = value, value.count > 18 else {
        return nil
    }
    return syncSessionExpiresFormatter.date(from: value[0...18])
}, toJSON: { (value: Date?) -> String? in
    guard let value = value else {
        return nil
    }
    return syncSessionExpiresFormatter.string(from: value)
})

/// Sync session object, stored inside local Store document after calling to API server for authentication.
class SyncSession: BaseModel {
    /// The sync session token.
    var sessionID = ""
    /// The sync session cooki name to use.
    var cookieName = ""
    /// The sync session
    var expires: Date?

    override func mapping(map: Map) {
        super.mapping(map: map)
        sessionID <- map["session_id"]
        cookieName <- map["cookie_name"]
        expires <- (map["expires"], expiresTransform)
    }
}

extension SyncSession {
    /// True if there are values for token and name and that the token is not yet expired.
    var isValid: Bool {
        return sessionID.isNotEmpty && cookieName.isNotEmpty && expires != nil && expires! > Date()
    }
}
