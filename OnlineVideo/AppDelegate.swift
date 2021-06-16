//
//  AppDelegate.swift
//  OnlineVideo
//
//  Created by 刘耀宗 on 2021/6/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navc = UINavigationController(rootViewController: TestViewController())
        window = UIWindow(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        window?.rootViewController = navc
        window?.makeKeyAndVisible()
        return true
    }



}

