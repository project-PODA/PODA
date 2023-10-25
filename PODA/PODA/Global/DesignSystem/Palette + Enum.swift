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
    case podaRed
    case podaGray1
    case podaGray2
    case podaGray3
    case podaGray4
    case podaGray4_1
    case podaGray5
    case podaGray6
    
    func getColor() -> UIColor {
        switch self {
        case .podaWhite:
            return UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        case .podaBlue:
            return UIColor(red: 97/255, green: 154/255, blue: 238/255, alpha: 1)
        case .podaBlack:
            return UIColor(red: 28/255, green: 29/255, blue: 30/255, alpha: 1)
        case .podaRed:
            return UIColor(red: 255/255, green: 111/255, blue: 102/255, alpha: 1)
        case .podaGray1:
            return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        case .podaGray2:
            return UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
        case .podaGray3:
            return UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
        case .podaGray4:
            return UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        case .podaGray4_1:
            return UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        case .podaGray5:
            return UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        case .podaGray6:
            return UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        }
    }
}

