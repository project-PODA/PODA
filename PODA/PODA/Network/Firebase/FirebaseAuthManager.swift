//
//  FirebaseAuthManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth

class FireAuthManager {
    let firebaseDBManager = FirestorageDBManager()
    let fireStorageImageManager = FireStorageImageManager()
    
    func userLogin(email : String, password: String, completion: @escaping (FireAuthError) -> Void){
        DispatchQueue.global(qos: .background).async{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                } else {
                    print("로그인 성공")
                    completion(.none)
                }
            }
        }
    }
    func createUser(email: String, password: String, completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos:.background).async{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                } else {
                    print("유저 생성 성공")
                    completion(.none)
                }
            }
        }
    }
            

    
    func signUpUser(email: String, password: String, profileImage: Data?, nickName: String, completion: @escaping (FireAuthError) -> Void) {
        
        let userInfo = UserInfo(createDate: Date().GetCurrentTime(), loginDate: "", isUsing: false, image: profileImage, userNickname: nickName, email: email, password: password, followers: [], followings: [])
        
        DispatchQueue.global(qos: .background).async{
            self.createUser(email: email, password: password) { createUserError in
                if createUserError != .none {
                    Logger.writeLog(.error, message: "유저 생성 중 예상치 못한 에러 발생")
                    completion(.unknown)
                    return
                }
                self.userLogin(email: email, password: password) { loginError in
                    if loginError != .none {
                        Logger.writeLog(.error, message: "유저 로그인 중 예상치 못한 에러 발생")
                        completion(.unknown)
                        return
                    }
                    
                    self.firebaseDBManager.createUser(userInfo: userInfo) { dbManagerError in
                        if dbManagerError != .none {
                            Logger.writeLog(.error, message: "유저 정보 생성 중 문제 발생")
                            completion(.unknown)
                            return
                        }
                        
                        if let profileImage = profileImage {
                            self.fireStorageImageManager.createProfileImage(imageData: profileImage) { storageError in
                                if storageError != .none {
                                    print("프로필 이미지 생성 실패")
                                    Logger.writeLog(.error, message: "프로필 이미지 생성 실패")
                                    completion(.unknown)
                                } else {
                                    print("프로필 이미지 성공")
                                    completion(.none)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
