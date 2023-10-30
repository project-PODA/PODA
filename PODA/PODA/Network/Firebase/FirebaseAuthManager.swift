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
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
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
                Logger.writeLog(.error, message: "[\(FireAuthError.logoutFailed)] : \(FireAuthError.logoutFailed.description)")
                completion(.error(FireAuthError.logoutFailed.code, FireAuthError.logoutFailed.description))
            }
        }
    }
    
    func createUser(email: String, password: String, completion: @escaping (FireAuthError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                } else {
                    completion(.none)
                }
            }
        }
    }

    func deleteEmail(completion: @escaping (FireAuthError) -> Void) {
        
        if let currentUser = Auth.auth().currentUser {
            let userEmail = UserDefaultManager.userEmail
            let userPassword = UserDefaultManager.userPassword
            let credential = EmailAuthProvider.credential(withEmail: userEmail, password: userPassword)
            currentUser.reauthenticate(with: credential) { authDataResult, reauthError in
                if let reauthErrCode = reauthError as NSError? {
                    Logger.writeLog(.error, message: "[\(reauthErrCode.code)] : \(reauthErrCode.description)")
                    completion(.error(reauthErrCode.code, reauthErrCode.localizedDescription))
                } else {
                    currentUser.delete { deleteError in
                        if let errCode = deleteError as NSError? {
                            Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                            completion(.error(errCode.code, errCode.localizedDescription))
                        } else {
                            completion(.none)
                        }
                    }
                }
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
                    completion(.error(deleUserError.code, deleUserError.description))
                    return
                }
                self.firestorageDBManager.deleteCollection(collection : currentUserUID) { deleteCollectionError in
                    if deleteCollectionError != .none {
                        Logger.writeLog(.error, message: "UUID Collection 삭제 중 문제 발생")
                        completion(.error(deleteCollectionError.code, deleteCollectionError.description))
                        return
                    }
                }
                
                self.firestorageImageManager.deleteTopFolder() { deleteTopFolder in
                    if deleteTopFolder != .none {
                        Logger.writeLog(.error, message: "Storage 폴더 삭제 중 문제 발생")
                        completion(.error(deleteTopFolder.code, deleteTopFolder.description))
                        return
                        
                    }
                    self.deleteEmail() { deleteEmailError in
                        if deleteEmailError != .none {
                            Logger.writeLog(.error, message: "Authentification User 삭제 중 문제 발생")
                            completion(.error(deleteEmailError.code, deleteEmailError.description))
                            return
                        } else {
                            completion(.none)
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
                    completion(.error(createUserError.code, createUserError.description))
                    return
                }
                self.userLogin(email: email, password: password) { loginError in
                    if loginError != .none {
                        Logger.writeLog(.error, message: "유저 로그인 중 예상치 못한 에러 발생")
                        completion(.error(loginError.code, loginError.description))
                        return
                    }
                    
                    self.firestorageDBManager.createUserAccount(userInfo: userInfo) { dbManagerError in
                        if dbManagerError != .none {
                            Logger.writeLog(.error, message: "유저 정보 생성 중 문제 발생")
                            completion(.error(dbManagerError.code, dbManagerError.description))
                            return
                        }
                        
                        if let profileImage = profileImage {
                            self.firestorageImageManager.createProfileImage(imageData: profileImage) { storageError in
                                if storageError != .none {
                                    Logger.writeLog(.error, message: "프로필 이미지 생성 실패")
                                    completion(.error(storageError.code, storageError.description))
                                    return
                                } else {
                                    completion(.none)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
