//
//  UILabel + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UILabel {
    func setUpLabel(title: String, fontSize: LabelFontSize, isFontBold: Bool = true, titleColor: Palette = .gray) {
        self.text = title
        self.font = isFontBold ? UIFont.boldSystemFont(ofSize: fontSize.rawValue) : UIFont.systemFont(ofSize: fontSize.rawValue)
        let titleColor = titleColor.getColor()
        self.textColor = titleColor
    }
}

