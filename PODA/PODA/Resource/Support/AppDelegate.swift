//
//  AppDelegate.swift
//  PODA
//
//  Created by Kyle on 2023/10/13.
//

import UIKit
import FirebaseCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var filePath: String = ""
          #if DEBUG
          filePath = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
          #else
          filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
          #endif
          let options: FirebaseOptions? = FirebaseOptions.init(contentsOfFile: filePath)
          FirebaseApp.configure(options: options!)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

