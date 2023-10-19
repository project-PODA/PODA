//
//  FirebaseError + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

enum FireStorageDBError {
    case invalidURL
    case requestFailed
    case invalidData
    case unknown
    case none
}

enum FireStorageImageError {
    case ImageDataError
    case uploadFailed
    case downloadFailed
    case unknown
    case none
}
