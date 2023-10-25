//
//  UIFont + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/16.
//

import UIKit

enum PodaFont {
    case button1
    case body1
    case body2
    case subhead1
    case subhead2
    case subhead3
    case subhead4
    case caption
    case head1
    case display1
}

extension UIFont {
    static func podaFont(_ name: PodaFont) -> UIFont {
        switch name {
        case .button1:
            return UIFont(name: "Pretendard-Bold", size: 15) ?? UIFont()
        case .body1:
            return UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont()
        case .body2:
            return UIFont(name: "Pretendard-Regular", size: 16) ?? UIFont()
        case .subhead1:
            return UIFont(name: "Pretendard-Bold", size: 13) ?? UIFont()
        case .subhead2:
            return UIFont(name: "Pretendard-Bold", size: 14) ?? UIFont()
        case .subhead3:
            return UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont()
        case .subhead4:
            return UIFont(name: "Pretendard-Bold", size: 19) ?? UIFont()
        case .caption:
            return UIFont(name: "Pretendard-Regular", size: 13) ?? UIFont()
        case .head1:
            return UIFont(name: "Pretendard-Bold", size: 24) ?? UIFont()
        case .display1:
            return UIFont(name: "Pretendard-Regular", size: 30) ?? UIFont()
            
        }
    }
}
