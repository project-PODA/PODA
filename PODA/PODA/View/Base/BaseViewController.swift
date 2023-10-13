//
//  BaseViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

protocol UIConfigurable{
    func configUI()
}

class BaseViewController : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
