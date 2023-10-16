//
//  BaseTabbarController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

class BaseTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let mainVC = MainViewController(viewModel: MainViewModel())
        let mainNavVC = BaseNavigationController(rootViewController: mainVC)
        mainVC.bind(to: mainVC.viewModel)
        mainNavVC.tabBarItem = UITabBarItem(title: "메인", image:  UIImage(systemName: "person.circle"), tag: 0)
        
        let profileVC = ProfileViewController(viewModel: ProfileViewModel())
        let profileNavVC = BaseNavigationController(rootViewController: profileVC)
        profileVC.bind(to: profileVC.viewModel)
        profileNavVC.tabBarItem = UITabBarItem(title: "마이페이지", image:  UIImage(systemName: "person.circle"), tag: 1)
        
        viewControllers = [mainNavVC, profileNavVC]
    }
    
}
