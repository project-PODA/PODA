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
}

