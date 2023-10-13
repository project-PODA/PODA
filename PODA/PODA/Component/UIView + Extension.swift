//
//  UIView + Extension.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
//

import UIKit

extension UIView{
    func setUpView(backgroundColor : Palette = .white ,borderColor : Palette = .white, borderWidth : CGFloat = 0 ){
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.backgroundColor = backgroundColor.getColor().cgColor
        self.layer.borderColor = borderColor.getColor().cgColor
        self.layer.borderWidth = borderWidth
    }
}
