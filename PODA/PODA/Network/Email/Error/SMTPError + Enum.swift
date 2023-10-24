//
//  SMTPError + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/23.
//

import Foundation

enum SMTPError: Equatable {
    case wrongEmail
    case worngFileFormat
    case noImage
    case error(Int, String)
    case none
    var description: String {
        switch self {
            case .wrongEmail:
                return "잘못된 주소 형식 입니다."
            case .noImage:
                return "사진정보를 찾을수 없습니다."
            case .worngFileFormat:
                return "잘못된 사진 형식입니다."
            case let .error(errCode, message):
                return "[\(errCode)]: \(message)"
            case .none:
                return "none"
        }
    }
    var code: Int {
        switch self {
            case .wrongEmail:
                return 9999
            case .noImage:
                return 10000
            case .worngFileFormat:
                return 10001
            case .none:
                return 0
            default:
                return -1
        }
    }
}
