//
//  UITextField + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UITextField {
    func setUpTextField(delegate : UITextFieldDelegate) {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        self.leftView = leftPaddingView
        self.leftViewMode = .always
        self.delegate = delegate
    }
}
