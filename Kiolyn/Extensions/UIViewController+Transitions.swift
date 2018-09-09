//
//  UIViewController+Transitions.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/23/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension UIViewController {
    /// Change root view controller
    ///
    /// - Parameter root: The new root controller.
    func change(root controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.transition(with: window, duration: 0.3, options: .curveLinear, animations: {
            window.rootViewController = controller
            window.makeKeyAndVisible()
        })
    }
}
