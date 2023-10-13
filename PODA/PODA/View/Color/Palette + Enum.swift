//
//  Palette + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

enum Palette {
    case white
    case boldPink
    case pink
    case purple
    case red
    case lightRed
    case lightBlue
    case lightGreen
    case lightYellow
    case lightBlack //큰타이틀용?
    case lightGray //소제목용?
    case lightGrayTest //소제목용?
    case gray // 텍스트용?
    case black
    
    func getColor() -> UIColor {
        switch self {
        case .lightYellow:
            return UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        case .lightGreen:
            return UIColor(red: 102/255, green: 255/255, blue: 102/255, alpha: 1)
        case .red:
            return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        case .boldPink:
            return UIColor(red: 255/255, green: 199/255, blue: 199/255, alpha: 1)
        case .pink:
            return UIColor(red: 255/255, green: 226/255, blue: 226/255, alpha: 1)
        case .white:
            return UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        case .purple:
            return UIColor(red: 135/255, green: 133/255, blue: 162/255, alpha: 1)
        case .lightBlack:
            return UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
        case .lightGray:
            return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
        case .lightGrayTest:
            return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 0.8)
        case .gray:
            return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
        case .lightBlue:
            return UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        case .lightRed:
            return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 0.5)
        case .black:
            return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        }
    }
}

