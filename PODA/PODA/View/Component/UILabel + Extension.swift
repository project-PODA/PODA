//
//  UILabel + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UILabel {
    func setUpLabel(title: String, fontSize: LabelFontSize, isFontBold: Bool = true) {
        self.text = title
        self.font = isFontBold ? UIFont.boldSystemFont(ofSize: fontSize.rawValue) : UIFont.systemFont(ofSize: fontSize.rawValue)
    }
}

