//
//  CustomTabBarController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/20.
//

import UIKit

class CustomTabBarController: UITabBarController {

    private let customTabBarView = UIView()
       private let homeButton = UIButton()
       private let personButton = UIButton()

       override func viewDidLoad() {
           super.viewDidLoad()

           setupCustomTabBar()
       }

       private func setupCustomTabBar() {
           tabBar.isHidden = true

           customTabBarView.backgroundColor = .clear
           customTabBarView.frame = CGRect(x: (view.bounds.width - 148) / 2, y: view.bounds.height - 60, width: 148, height: 60)
           customTabBarView.layer.cornerRadius = 30
           customTabBarView.layer.masksToBounds = true
           customTabBarView.backgroundColor = .white

           view.addSubview(customTabBarView)

           homeButton.frame = CGRect(x: 5, y: 0, width: 60, height: 60)
           homeButton.setImage(UIImage(named: "icon_home"), for: .normal)
           homeButton.addTarget(self, action: #selector(didTapHome), for: .touchUpInside)
           homeButton.layer.cornerRadius = 30
           homeButton.backgroundColor = .white
           customTabBarView.addSubview(homeButton)

           personButton.frame = CGRect(x: customTabBarView.bounds.width - 65, y: 0, width: 60, height: 60)
           personButton.setImage(UIImage(named: "icon_person"), for: .normal)
           personButton.addTarget(self, action: #selector(didTapPerson), for: .touchUpInside)
           personButton.layer.cornerRadius = 30
           personButton.backgroundColor = .white
           customTabBarView.addSubview(personButton)
       }

       @objc private func didTapHome() {
           self.selectedIndex = 0
       }

       @objc private func didTapPerson() {
           self.selectedIndex = 1
       }

}
