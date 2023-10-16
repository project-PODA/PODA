//
//  UIButton + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UIButton {
    func setUpButton(title: String, podaFont: PodaFont) {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.podaFont(podaFont)
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

