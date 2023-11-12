//
//  LoginViewModel.swift
//  PODA
//
//  Created by 배은서 on 11/10/23.
//

import Foundation
import UIKit

class LoginViewModel {
    private let fireAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    
    func handleDebugLoginButton(_ completion: @escaping ((_ userInfo: SignUpUserInfo?, _ error: FireAuthError?) -> ())) {
        let originalString = "test@naver.com"
        let randomPart = originalString.randomString(length: 8)
        
        let userInfo = SignUpUserInfo(
            email: originalString.replacingOccurrences(of: "test", with: randomPart),
            password: "Poda1!",
            profileImage: UIImage(named: "image_profile")?.pngData(),
            nickName: "랜덤계정")
        
        LoginAPI.shared.debugLogin(userInfo) { result in
            switch result {
            case .success(let userInfo):
                print("랜덤계정 생성 성공! 로그인 진입중..")
                completion(userInfo, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func handleLoginButton(_ userInfo: LoginUserInfo , _ completion: @escaping ((_ userInfo: LoginUserInfo?, _ error: FireAuthError?) -> ())) {
        LoginAPI.shared.login(userInfo) { result in
            switch result {
            case .success(let userInfo):
                print("⭐️ 로그인 성공!")
                completion(userInfo, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
