//
//  BaseTabbarController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

class BaseTabbarController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let mainVC = MainViewController(viewModel : MainViewModel())
        mainVC.tabBarItem = UITabBarItem(title: "First", image:  UIImage(systemName: "person.circle"), tag: 0)
        
        let secondVC = ProfileViewController(viewModel : ProfileViewModel())
        
        secondVC.tabBarItem = UITabBarItem(title: "Second", image: UIImage(systemName: "book.circle"), tag: 1)
        
        viewControllers = [mainVC, secondVC]
        selectedIndex = 0
    }
    
}
