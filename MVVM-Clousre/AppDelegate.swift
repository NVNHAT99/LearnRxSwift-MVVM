//
//  AppDelegate.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/12/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = HomeViewController(viewModel: HomeViewModel())
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        window.rootViewController = mainNavigationController
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

