//
//  BaseTabbarController.swift
//  temp
//
//  Created by 박유경 on 2023/10/10.
//

import UIKit
class BaseTabbarController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let firstViewController = tempController(viewModel : tempViewViewModel())
        firstViewController.tabBarItem = UITabBarItem(title: "First", image:  UIImage(systemName: "person.circle"), tag: 0)
        
        let secondViewController = tempController(viewModel : tempViewViewModel())
        secondViewController.tabBarItem = UITabBarItem(title: "Second", image: UIImage(systemName: "book.circle"), tag: 1)
        
        viewControllers = [firstViewController, secondViewController]
        selectedIndex = 0
    }
    
}
