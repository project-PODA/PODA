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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // 배경색에 따라서 상태바 색상 변경되도록
        return view.backgroundColor == UIColor.white ? .darkContent : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let className = String(describing: type(of: self))
        if className == "LoginViewController" || className == "SignUpViewController" || className == "SetProfileViewController" || className == "AgreeTermsViewController" {
            view.backgroundColor = .white
        } else if className == "CompleteSignUpViewController" {
            view.backgroundColor = Palette.podaBlue.getColor()
        } else {
            view.backgroundColor = Palette.podaBlack.getColor()
        }

        // 배경색 설정 후 상태바 업데이트를 요청
        setNeedsStatusBarAppearanceUpdate()
    }
}

