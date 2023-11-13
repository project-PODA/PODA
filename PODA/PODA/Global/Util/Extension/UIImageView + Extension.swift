//
//  UIImageView + Extension.swift
//  PODA
//
//  Created by 랑 on 11/11/23.
//

import UIKit

extension UIImageView {
    func addShadowToImageView() {
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 7
        self.layer.shadowColor = Palette.podaBlack.getColor().cgColor
    }
}
