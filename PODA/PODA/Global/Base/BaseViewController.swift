//
//  BaseViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

protocol UIConfigurable {
    func configUI()
}


class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let className = String(describing: type(of: self))
        if className == "LoginViewController" || className == "SignUpViewController" || className == "SetProfileViewController" {
            view.backgroundColor = .white
        } else {
            view.backgroundColor = Palette.podaBlack.getColor()
        }
    }
}
