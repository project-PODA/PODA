//
//  FrameRate + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

enum FrameRate: String {
    case OneToOne = "OneToOne"
    case ThirdToFourth = "ThirdToFourth"
    
    func toString() -> String {
        return self.rawValue
    }
}
