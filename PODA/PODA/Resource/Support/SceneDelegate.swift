//
//  SceneDelegate.swift
//  PODA
//
//  Created by Kyle on 2023/10/13.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 앱 전체 다크모드 막기
        window?.overrideUserInterfaceStyle = .light
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if UserDefaultManager.isUserLoggedIn {
            switchToMainPage()
        } else {
            let loginViewController = LoginViewController()
            let navigationController = BaseNavigationController(rootViewController: loginViewController)
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
    }
    
    //로그인 뷰 컨트롤러를 스택에서 제거하고, 메인페이지로 전환하기
    func switchToMainPage() {
        let tabBarController = BaseTabbarController()
        let navigationController = BaseNavigationController(rootViewController: tabBarController)
        
        if let window = self.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navigationController
            })
        }
    }
    
    
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}


