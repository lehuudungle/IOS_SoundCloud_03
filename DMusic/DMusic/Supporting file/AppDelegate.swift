//
//  AppDelegate.swift
//  DMusic
//
//  Created by le.huu.dung on 9/5/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = MainController.shared
        self.window?.makeKeyAndVisible()
        return true
    }
}
