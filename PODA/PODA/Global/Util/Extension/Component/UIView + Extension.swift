//
//  UIView + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UIView {
    func setUpView() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    func transfromToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(.init(width: bounds.size.width, height: bounds.size.height), isOpaque, 0.5)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
