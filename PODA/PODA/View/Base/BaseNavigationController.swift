//
//  BaseNavigationController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

class BaseNavigationController: UINavigationController {
    var rootViewController: UIViewController?
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.rootViewController = rootViewController
        //configTheme()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private func configTheme() {
        interactivePopGestureRecognizer?.isEnabled = true
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .white
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = UIColor.black
    }
}

