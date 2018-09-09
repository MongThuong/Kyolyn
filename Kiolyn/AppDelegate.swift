//
//  AppDelegate.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/2/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import SnapKit
import Fabric
import Crashlytics
import RxSwift

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // https://www.fabric.io/kits/ios/crashlytics/manual-install?step=3
        Fabric.with([Crashlytics.self])
        // https://www.fabric.io/kits/ios/crashlytics/features
        SP.authService.currentIdentity
            .subscribe(onNext: { id in
                // Define user whenever got logging in
                guard let id = id else {
                    return
                }
                // Define the user
                let ins = Crashlytics.sharedInstance()
                ins.setObjectValue(id.store.name, forKey: "Store")
                ins.setObjectValue(id.station.name, forKey: "Station")
                ins.setUserIdentifier(id.employee.id)
                ins.setUserName(id.employee.name)
            })
            .disposed(by: disposeBag)
        
        // Show login screen
        let vc = LoginController.singleInstance
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        SP.authService.signout()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SP.restClient.restartEventClientIfStopped()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
