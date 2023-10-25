//
//  FirebaseAuthManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth

class FireAuthManager {
    private let firestorageDBManager: FirestorageDBManager
    private let firestorageImageManager: FireStorageImageManager
    
    init(firestorageDBManager: FirestorageDBManager, firestorageImageManager: FireStorageImageManager) {
        self.firestorageDBManager = firestorageDBManager
        self.firestorageImageManager = firestorageImageManager
    }
    
    func userLogin(email: String, password: String, completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func userLogOut(completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async{
            do {
                try Auth.auth().signOut()
                completion(.none)
            } catch  {
                Logger.writeLog(.error, message: "[\(FireAuthError.logoutFailed)] : \(error.localizedDescription)")
                completion(.error(FireAuthError.logoutFailed.code, FireAuthError.logoutFailed.description))
            }
        }
    }
    
    func createUser(email: String, password: String, completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func deleteEmail(completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async{
            if let currentUser = Auth.auth().currentUser {
                currentUser.delete { error in
                    if let err = error as NSError? {
                        Logger.writeLog(.error, message: "[\(err.code)] : \(err.localizedDescription)")
                        completion(.error(err.code, err.localizedDescription))
                    } else {
                        completion(.none)
                    }
                }
            } else {
                Logger.writeLog(.error, message: "유저 계정 삭제 중 문제 발생")
                completion(.unknown)
            }
        }
    }
    
    func deleteAccount(completion: @escaping (FireAuthError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }

        DispatchQueue.global(qos: .userInteractive).async {
            self.firestorageDBManager.deleteUserMail { deleUserError in
                if deleUserError != .none{
                    Logger.writeLog(.error, message: "User Email 삭제 중 문제 발생")
                    completion(.unknown)
                    return
                }
                self.firestorageDBManager.deleteCollection(collection : currentUserUID) { deleteCollectionError in
                    if deleteCollectionError != .none {
                        Logger.writeLog(.error, message: "UUID Collection 삭제 중 문제 발생")
                        completion(.unknown)
                        return
                    }
                }
                
                self.firestorageImageManager.deleteTopFolder() { deleteTopFolder in
                    if deleteTopFolder != .none {
                        Logger.writeLog(.error, message: "Storage 폴더 삭제 중 문제 발생")
                        completion(.unknown)
                        return
                        
                    }
                    self.deleteEmail() { deleteEmailError in
                        if deleteEmailError != .none {
                            Logger.writeLog(.error, message: "Authentification User 삭제 중 문제 발생")
                            completion(.unknown)
                            return
                        }
                    }
                }
            }
        }
    }

    func signUpUser(email: String, password: String, profileImage: Data?, nickName: String, completion: @escaping (FireAuthError) -> Void) {
        
        let userInfo = UserInfo(createDate: Date().GetCurrentTime(), loginDate: "", isUsing: false, userNickname: nickName, email: email, followers: [], followings: [])
        
        DispatchQueue.global(qos: .userInteractive).async {
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
                    
                    self.firestorageDBManager.createUserAccount(userInfo: userInfo) { dbManagerError in
                        if dbManagerError != .none {
                            Logger.writeLog(.error, message: "유저 정보 생성 중 문제 발생")
                            completion(.unknown)
                            return
                        }
                        
                        if let profileImage = profileImage {
                            self.firestorageImageManager.createProfileImage(imageData: profileImage) { storageError in
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
