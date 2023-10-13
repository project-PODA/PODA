//
//  BaseViewController.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
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
