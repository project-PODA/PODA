//
//  LoginAPI.swift
//  PODA
//
//  Created by 배은서 on 11/10/23.
//

import Foundation

final class LoginAPI {
    static let shared = LoginAPI()
    
    private let fireAuthManager = FireAuthManager(
        firestorageDBManager: FirestorageDBManager(),
        firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    
    private init() {}
    
    func login(_ userInfo: LoginUserInfo, _ completion: @escaping ((Result<LoginUserInfo, FireAuthError>) -> ())) {
        fireAuthManager.userLogin(email: userInfo.email, password: userInfo.password) { error in
            if error == .none {
                completion(.success(userInfo))
            } else {
                completion(.failure(error))
            }
        }
    }
    
    func debugLogin(_ userInfo: SignUpUserInfo, _ completion: @escaping ((Result<SignUpUserInfo, FireAuthError>) -> ())) {
        fireAuthManager.signUpUser(
            email: userInfo.email,
            password: userInfo.password,
            profileImage: userInfo.profileImage,
            nickName: userInfo.nickName) { error in
                if error == .none {
                    completion(.success(userInfo))
                } else {
                    completion(.failure(error))
                }
            }
    }
}
