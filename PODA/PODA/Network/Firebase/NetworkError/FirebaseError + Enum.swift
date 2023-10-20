//
//  FirebaseError + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

enum FireStorageDBError {
    case invalidURL
    case invalidData
    case unknown
    case none
}

enum FireStorageImageError {
    case uploadFailed
    case unknown
    case none
}

enum FireAuthError: Equatable {
    case unknown
    case error(Int, String)
    case none
}
