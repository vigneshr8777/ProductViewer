//
//  AppDelegate.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let listCoordinator = ProductListCoordinator()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = listCoordinator.getProductListController()
        window?.makeKeyAndVisible()
        
        return true
    }

   


}

