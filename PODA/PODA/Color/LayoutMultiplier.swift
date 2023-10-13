//
//  LayoutMultiplier.swift
//  temp
//
//  Created by 박유경 on 2023/10/10.
//

import Foundation
enum LayoutMultiplier: CGFloat {
    case superSmall = 0.02
    case small = 0.05
    case quarter = 0.25
    case half = 0.5
    case slightlyMoreThanHalf = 0.6
    func getScale() -> Double {
        switch self{
        case .superSmall:
            return 0.02
        case .small:
            return 0.05
        case .quarter:
            return 0.25
        case .half:
            return 0.5
        case .slightlyMoreThanHalf:
            return 0.6
        }
    }
}
