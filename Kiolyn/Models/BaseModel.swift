//
//  BaseModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Base class for all data model.
class BaseModel: NSObject, Mappable {
    // Time will be used for `id` calculating with precision of hundreds of milliseconds. This has proved to work fine on Web/PC, so keep using this for consistency among systems.
    static var idFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyMMddHHmmssSS"
        return df
    }
    /// The empty ID value.
    static let idEmpty = "00000000000000"
    /// Return a new based on the `idFormatter` using the current time.
    static var newID: String { return BaseModel.idFormatter.string(from: Date()) }
    /// Return the timestamp in ID date format. Same as NewId but different meaning, thus we need separate method.
    static var timestamp: String { return BaseModel.idFormatter.string(from: Date()) }
    
    /// Document type of this class, child class MUST override to provide the correct type value.
    class var documentType: String { return "" }
    /// The prefix to be used for calculating the document id.
    class var documentIDPrefix: String { return "" }
    /// Classes that support `loadAll` method, must override this to provide the mapping for all query.
    class var allMapBlock: CBLMapBlock? { return nil }

    /// Document id, normally of the form `type`_`id`.
    var documentID = ""
    /// Current revision.
    var revision = ""
    /// The object type
    var type = ""
    /// Return the channels list that this object is segemented to.
    var channels: [String] = []
    /// The id of this object.
    var id = ""
    /// The name of the object.
    var name = ""
    /// The Store (Id) that this object is bound to.
    var storeID = ""
    /// The  Merchant (Id) that this object is bound to.
    var merchantID = ""
    /// `true` if this model at least once got saved to the database, `false` if it is completely new model.
    var hasRevision: Bool { return revision.isNotEmpty }
    /// True if there is a valid ID for this model.
    var hasID: Bool { return id.isNotEmpty }
    /// Return the created date of an object by parsing its Id.
    var createdTime: Date { return BaseModel.idFormatter.date(from: id)! }
    /// True if there is a valid ID for this model.
    var hasStoreID: Bool { return storeID.isNotEmpty }
    /// Last updated time
    var updatedAt = ""
    /// Last updated by user ID.
    var updatedBy = ""

    /// Object description
    public override var description: String {
        return "\(documentID)/\(id)/\(name)"
    }
    
    init(id: String) {
        self.id = id
        self.type = BaseModel.documentType
    }
    
    convenience override init() {
        self.init(id: BaseModel.newID)
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        documentID <- map["_id"]
        revision <- map["_rev"]
        type <- map["type"]
        channels <- map["channels"]
        id <- map["id"]
        name <- map["name"]
        storeID <- map["storeid"]
        merchantID <- map["merchantid"]
        updatedAt <- map["updated_at"]
        updatedBy <- map["updated_by"]
    }
}

extension BaseModel {
    
    /// Clone the current model without some keys
    ///
    /// - Parameter keys: the list of keys to be removed
    /// - Returns: the new object without given keys
    func clone<T: BaseModel>(without keys: [String] = []) -> T {
        var properties = toJSON()
        for key in keys {
            properties.removeValue(forKey: key)
        }
        return T(JSON: properties)!
    }
}

/// Represent an object that can be displayed on Grid, so far we have Category/Item/Modifier Option are the object that must conform to this protocol.
class GridItemModel: BaseModel {
    /// The column position on ordering grid.
    var col: Int = -1
    /// The row position on ordering grid.
    var row: Int = -1
    /// Background color to be displayed.
    var color: String = ""
    
    /// True if both row and col containing meaningful values.
    var hasPosition: Bool {
        return row >= 0 && col >= 0
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        col <- map["col"]
        row <- map["row"]
        color <- map["color"]
    }
}
