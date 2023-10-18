//
//  FirebaseError + Enum.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

enum FireStorageDBError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData

}

enum FireStorageImageError : Error{
    case ImageDataError
    case uploadFailed
    case downloadFailed
    case unknown
}
