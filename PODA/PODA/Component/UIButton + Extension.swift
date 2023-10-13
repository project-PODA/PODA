//
//  UIButton + Extension.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
//

import UIKit
extension UIButton {
    func setUpButton(title: String, titleSize : CGFloat = 20.0 ,titleColor : Palette = .white ,backgroundColor: Palette = .purple) {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.backgroundColor = backgroundColor.getColor()
        setTitle(title, for: .normal)
        let boldFont = UIFont.boldSystemFont(ofSize: titleSize)
        self.titleLabel?.font = boldFont
        setTitleColor(titleColor.getColor(), for: .normal)
        
    }
    
    func resizeImageButton(image: UIImage?, width: Int, height: Int, color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        let newSize = CGSize(width: width, height: height)
        let coloredImage = image.withTintColor(color)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        coloredImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
