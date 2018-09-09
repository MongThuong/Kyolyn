//
//  RestClient.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/3/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import SwiftWebSocket

enum RestClientError: LocalizedError {
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response"
        }
    }
}

class RestClient {
 
    /// Hold the websocket object to main.
    var eventWS: WebSocket? = nil
        
    /// Return the main URL
    var mainURL: URL? {
        return SP.stationManager.mainStation.value?.0
    }
    
    var db: Database {
        return SP.database
    }
    
    var id: Identity? {
        return SP.authService.currentIdentity.value
    }
    
    var store: Store? {
        return id?.store
    }
    
    var station: Station? {
        return id?.station
    }
    
    let queue = DispatchQueue(label: "com.willbe.kiolyn.rest-client", qos: .utility, attributes: [.concurrent])
    let disposeBag = DisposeBag()
    
    init() {
        SP.stationManager.mainStation
            .subscribe(onNext: { main in
                self.start(eventClient: main?.0)
            })
            .disposed(by: disposeBag)
    }
}
