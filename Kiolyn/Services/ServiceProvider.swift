//
//  SP.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Dip

typealias SP = ServiceProvider

/// Dictionary of all the services used inside the system.
class ServiceProvider {
    private static var _container: DependencyContainer?
    
    ///  The single container for all services injection
    static var container: DependencyContainer {
        set { _container = newValue }
        get { return _container ?? defaultContainer }
    }
    
    // Default service implementation
    private static let defaultContainer: DependencyContainer = DependencyContainer { (container: DependencyContainer) in
        container.register(.singleton) { XCGLoggingService() as LoggingService }
        container.register(.singleton) { CouchbaseDatabase() as Database }
        container.register(.singleton) { AuthenticationService() as AuthenticationService }
        container.register(.singleton) { DataService() as DataService }
        container.register(.singleton) { NavigationManager() as NavigationManager }
        container.register(.singleton) { OrderManager() as OrderManager }
        container.register(.singleton) { StationManager() as StationManager }
        container.register(.singleton) { DatabaseTimeCardService() as TimeCardService }
        container.register(.singleton) { StarIOPrintingService() as PrintingService }
        container.register(.singleton) { BrotherLabelPrintingService() as LabelPrintingService }
        container.register(.singleton) { PaxCCService() as CCService }
        container.register(.singleton) { RestClient() as RestClient }
        container.register(.singleton) { RestEmailService() as EmailService }
        container.register(.singleton) { IdleManager() as IdleManager }
    }
    
    /// The logging service instance.
    static var logger: LoggingService { return try! container.resolve() as LoggingService }
    ///  The database access instance.
    static var database: Database { return try! container.resolve() as Database }
    ///  The authentication service instance.
    static var authService: AuthenticationService { return try! container.resolve() as AuthenticationService }
    /// The data service instance.
    static var dataService: DataService { return try! container.resolve() as DataService }
    /// The rest client to fetch data from Main.
    static var restClient: RestClient { return try! container.resolve() as RestClient }
    ///  The printing service instance.
    static var printingService: PrintingService { return try! container.resolve() as PrintingService }
    ///  The label printing service instance.
    static var labelPrintingService: LabelPrintingService { return try! container.resolve() as LabelPrintingService }
    ///  The email service instance.
    static var emailService: EmailService { return try! container.resolve() as EmailService }
    ///  The credit card service instance.
    static var ccService: CCService { return try! container.resolve() as CCService }
    /// The timecard service instance.
    static var timecard: TimeCardService { return try! container.resolve() as TimeCardService }
    /// The order manager.
    static var orderManager: OrderManager { return try! container.resolve() as OrderManager }
    /// The navigation manager.
    static var navigation: NavigationManager { return try! container.resolve() as NavigationManager }
    /// The order manager.
    static var stationManager: StationManager { return try! container.resolve() as StationManager }
    /// The idle detector.
    static var idleManager: IdleManager { return try! container.resolve() as IdleManager }
}
