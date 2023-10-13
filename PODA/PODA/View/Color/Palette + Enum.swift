//
//  Palette + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

enum Palette {
    case podaWhite
    case podaBlue // 추억다이어리 셀 색깔
    case podaBlack
    func getColor() -> UIColor {
        switch self {
        case .podaWhite:
            return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        case .podaBlue:
            return UIColor(red: 97/255, green: 154/255, blue: 238/255, alpha: 1)
        case .podaBlack:
            return UIColor(red: 14/255, green: 14/255, blue: 14/255, alpha: 1)
        }
    }
}

