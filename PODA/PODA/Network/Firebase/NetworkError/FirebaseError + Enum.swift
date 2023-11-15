//
//  FirebaseError + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

enum FireStorageDBError: Equatable {
    case unknown
    case error(Int, String)
    case unavailableUUID
    case documentEmpty
    case decodingError
    case fieldEmpty
    case none
    var description: String {
        switch self {
            case .unknown:
                return "unknown"
            case let .error(errCode, message):
                return "[\(errCode)]: \(message)"
            case .unavailableUUID:
                return "[Storage]사용자의 UUID를 확인할 수 없습니다."
            case .documentEmpty:
                return "Document가 비어있습니다."
            case .decodingError:
                return "decoding 실패했습니다."
            case .fieldEmpty:
                return "field를 찾을수 없습니다."
            case .none:
                return "none"
        }
    }
    var code: Int {
        switch self {
            case .unknown:
                return 9999
            case .unavailableUUID:
                return 10001
            case .documentEmpty:
                return 10002
            case .decodingError:
                return 10003
            case .fieldEmpty:
                return 10004
            case .none:
                return 0
            default:
                return -1
        }
    }
}

enum FireStorageImageError: Equatable {
    case unknown
    case error(Int, String)
    case unavailableUUID
    case noFoundFile
    case none
    var description: String {
        switch self {
            case .unknown:
                return "unknown"
            case let .error(errCode, message):
                return "[\(errCode)] : \(message)"
            case .unavailableUUID:
                return "[FireStorage]: 사용자의 UUID를 확인할 수 없습니다."
            case .noFoundFile:
                return "파일/폴더를 찾을수 없거나 이미 삭제되었습니다."
            case .none:
                return "none"
        }
    }
    var code: Int {
        switch self {
            case .unknown:
                return 9999
            case .unavailableUUID:
                return 10001
            case .noFoundFile:
                return -13010
            case .none:
                return 0
            default:
                return -1
        }
    }
}

enum FireAuthError: Equatable, Error {
    case unknown
    case error(Int, String)
    case unavailableUUID
    case logoutFailed
    case retryLogin
    case none
    var description: String {
        switch self {
            case .unknown:
                return "unknown"
            case let .error(errCode, message):
                return "[\(errCode)]: \(message)"
            case .unavailableUUID:
                return "[FireAuth]: 사용자의 UUID를 확인할 수 없습니다."
            case .retryLogin:
                return "세션이 완료되었습니다. 다시 로그인합니다.."
            case .logoutFailed:
                return "로그아웃에 실패했습니다."
            case .none:
                return "none"
        }
    }
    var code: Int {
        switch self {
            case .unknown:
                return 9999
            case .unavailableUUID:
                return 10001
            case .logoutFailed:
                return 10002
            case .retryLogin:
                return 10003
            case .none:
                return 0
            default:
                return -1
        }
    }
}


