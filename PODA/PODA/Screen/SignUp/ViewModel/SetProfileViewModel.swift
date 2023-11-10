//
//  SetProfileViewModel.swift
//  PODA
//
//  Created by 박유경 on 2023/11/10.
//
import Foundation


enum NicknameValidStatus {
    case success
    case emptyText
    case exceedTextLength
    case none
}

enum CompleteSignUpValidStatus {
    case success
    case emptyText
    case exceedTextLength
    case profileImageEmpty
    case error(String)
    case none
}


class SetProfileViewModel {

    var profileImage: Observable<Data?> = Observable(nil)
    var nicknameText: Observable<String> = Observable("")
    var completeSignup: Observable<CompleteSignUpValidStatus> = Observable(.none)
    
    private var email = ""
    private var password = ""
    
    private let firebaseAuth: FireAuthManager
    init(firebaseAuth: FireAuthManager) {
        self.firebaseAuth = firebaseAuth
    }
    
    func updateData(email: String, password: String) {
        if email == "" || password == "" {
            return
        }
        self.email = email
        self.password = password
    }
    
    func setProfileImage(imageData: Data?) {
        guard let imageData = imageData else {
            profileImage.value = nil
            return
        }
        profileImage.value = imageData
    }
    
    func setNickName(nickname: String) {
        nicknameText.value = nickname
    }
    
    func onCompleteSingupTapped() {
        if profileImage.value == nil {
            completeSignup.value = .profileImageEmpty
            return
        }
        if nicknameText.value.isEmpty{
            completeSignup.value = .emptyText
            return
        }
        
        if nicknameText.value.count > 5 {
            completeSignup.value = .exceedTextLength
            return
        }
        print(nicknameText.value)

        firebaseAuth.signUpUser(email: email, password: password, profileImage: profileImage.value, nickName: nicknameText.value) { [weak self] error in
            guard let self = self else { return }
                if error == .none {
                    completeSignup.value = .success
                } else {
                    completeSignup.value = .error(error.description)
                }
            }
    }
}
