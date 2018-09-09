//
//  Customer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Customer` in the system, `Customer` are bound to Order created on `Area` that required customer info which are Delivery and ToGo.
class Customer: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "customer" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "cm" }
    /// Return ALL category that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Has a name
    override class var allMapBlock: CBLMapBlock? {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == documentType,
                let id = doc["id"] as? String, id.isNotEmpty,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                // having a good name
                let name = doc["name"] as? String, name.isNotEmpty else {
                    return
            }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            emit(storeID, nil)
        }
    }
    // private string phonePattern = @"\(?\d{3}\)?-? *\d{3}-? *-?\d{4}";
    // private string emailPattern = @"^(?("")("".+?(?<!\\)""@)|(([0-9a-z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-z])@))" +
    // @"(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-z][-\w]*[0-9a-z]*\.)+[a-z0-9][\-a-z0-9]{0,22}[a-z0-9]))$";
    var email = ""
    var mobilephone = ""
    var address = ""
    var country = ""
    var state = ""
    var city = ""
    var zip = ""
    var note = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        email <- map["email"]
        mobilephone <- map["mobilephone"]
        address <- map["address"]
        country <- map["country"]
        state <- map["state"]
        city <- map["city"]
        zip <- map["zip"]
        note <- map["note"]
    }
    
    // public string LastOrder
    // {
    //   get { return GetPropertyForName<string>("last_order_at"); }
    //   set { SetPropertyForName(value, "last_order_at"); }
    // }
    
    // public List<string> Orders
    // {
    //   get { return GetProperty<List<string>>(); }
    //   set { SetProperty(value); }
    // }
    
    // public bool IsEmpty
    // {
    //   get
    //   {
    //     // Make sure we won't query all empty
    //     return string.IsNullOrEmpty(Name) && string.IsNullOrEmpty(MobilePhone)
    //       && string.IsNullOrEmpty(Email) && string.IsNullOrEmpty(Address);
    //   }
    // }
    
    // public Customer() : base() { }
    // public Customer(IDictionary<string, object> document) : base(document) { }
    
    // public void UpdateMeta(Store store)
    // {
    //   Id = NewId;
    //   Type = "customer";
    //   Channels = new List<string> { store.Id };
    //   MerchantId = store.MerchantId;
    //   StoreId = store.Id;
    // }
    
    // public void AddOrder(Order order)
    // {
    //   if (!string.IsNullOrWhiteSpace(MobilePhone))
    //     MobilePhone = MobilePhone.Replace("_", "").Replace("-", "");
    //   if (!Orders.Contains(order.Id)) Orders.Add(order.Id);
    //   LastOrder = Timestamp;
    // }
    
    // public string FormattedPhone
    // {
    //   get { return FormatWithMask(MobilePhone, "###-###-####"); }
    // }
    
    // private string FormatWithMask(string input, string mask)
    // {
    //   if (string.IsNullOrWhiteSpace(input)) return input;
    //   var output = string.Empty;
    //   var index = 0;
    //   foreach (var m in mask)
    //   {
    //     if (m == '#')
    //     {
    //       if (index < input.Length)
    //       {
    //         output += input[index];
    //         index++;
    //       }
    //     }
    //     else output += m;
    //   }
    //   return output;
    // }
    
    // public bool IsPhoneValid
    // {
    //   get { return string.IsNullOrEmpty(MobilePhone) || Regex.IsMatch(MobilePhone, phonePattern); }
    // }
    
    // public bool IsEmailValid
    // {
    //   get { return string.IsNullOrEmpty(Email) || Regex.IsMatch(Email, emailPattern, RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250)); }
    // }
    
    // public bool IsValid
    // {
    //   get { return !string.IsNullOrWhiteSpace(Name) && IsPhoneValid && IsEmailValid; }
    // }
}


extension Customer {
    /// Create new `Customer`.
    ///
    /// - Parameters:
    ///   - database: The database to create in.
    ///   - store: The `Store` to create for.
    /// - Returns: The new `Customer`.
    /// - Throws: `ModelError` if given input is not valid or document could not be created.
    convenience init(inStore store: Store) {
        self.init()
        type = Customer.documentType
        channels = ["\(store.id)"]
        merchantID = store.merchantID
        storeID = store.id
    }
}


