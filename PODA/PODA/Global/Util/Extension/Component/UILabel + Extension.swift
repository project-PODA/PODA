//
//  UILabel + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UILabel {
    func setUpLabel(title: String, podaFont: PodaFont) {
        self.text = title
        self.font = UIFont.podaFont(podaFont)
    }
    
    func addShadowToLabel() {
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 7
        self.layer.shadowColor = Palette.podaBlack.getColor().cgColor
    }
}

