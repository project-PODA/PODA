//
//  ConstMargin + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import Foundation

enum SafeAreaConstMargin {
    case safeAreaTopMargin
    case safeAreaLeftMargin
    case safeAreaRightMargin
    case safeAreaBottomMargin
    
    func getMargin() -> Double {
        switch self {
        case .safeAreaTopMargin:
            return 10
        case .safeAreaLeftMargin:
            return 10
        case .safeAreaRightMargin:
            return 10
        case .safeAreaBottomMargin:
            return 10
        }
    }
}

enum ComponentSpacing {
    case small
    case medium
    case large
    
    func getMargin() -> Double {
        switch self {
        case .small:
            return 10
        case .medium:
            return 10
        case .large:
            return 10
        }
    }
}
