//
//  SignUpViewModel.swift
//  PODA
//
//  Created by Kyle on 11/9/23.
//

import UIKit

enum EmailTextValidStatus {
    case success
    case wrongFormat
    case none
}

enum AuthTextValidStatus {
    case success
    case wrongFormat
    case none
}

enum PasswordValidStatus {
    case success
    case wrongFormat
    case none
}

enum PasswordRepeatValidStatus {
    case success
    case wrongFormat
    case none
}

enum NextButtonValidStatus {
    case success
    case fail
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

class SignUpViewModel {
    
    var emailText: Observable<EmailTextValidStatus> = Observable(.none)
    var authText: Observable<AuthTextValidStatus> = Observable(.none)
    var passwordText: Observable<PasswordValidStatus> = Observable(.none)
    var passwordRepeatText: Observable<PasswordRepeatValidStatus> = Observable(.none)
    var isSignUpAllowed: Observable<Bool> {
        return Observable(emailAuthSuccess && authCodeSuccess && passwordAuthSuccess)
    }
    var completeSignup: Observable<CompleteSignUpValidStatus> = Observable(.none)
    
    private var email = ""
    private var password = ""
    private var profileImage = UIImage(named: "image_profile")?.pngData()
    private var nickName = "PODA"
    
    var emailAuthSuccess = false // 이메일 코드 전송 성공 여부
    var authCodeSuccess = false // 이메일 코드 인증 성공 여부
    var passwordAuthSuccess = false // 패스워드 일치 성공 여부
    var userAuthCode = 0
    var passwordResult = ""
    
    let firebaseAuthManager: FireAuthManager
    let fireStorageManager: FirestorageDBManager
    let smtpManager: SMTPManager
    let fireStoreDB = FirestorageDBManager()
    
    init(firebaseAuthManager: FireAuthManager, fireStorageManager: FirestorageDBManager, smtpManager: SMTPManager) {
        self.firebaseAuthManager = firebaseAuthManager
        self.fireStorageManager = fireStorageManager
        self.smtpManager = smtpManager
    }
    
    func setEmailText(email: String) {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        emailAuthSuccess = NSPredicate(format: "SELF MATCHES %@", emailFormat).evaluate(with: email)
        
        if emailAuthSuccess {
            emailText.value = .success
            self.email = email
        } else {
            emailText.value = .wrongFormat
        }
    }
    
    func checkAuthCode(inputCode: String) {
        if String(userAuthCode) == inputCode {
            authCodeSuccess = true
            authText.value = .success
        } else {
            authCodeSuccess = false
            authText.value = .wrongFormat
        }
    }
    
    func setPasswordText(password: String) {
        passwordResult = password
        let pattern = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{6,15}$"
        passwordAuthSuccess = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: password)
        
        if passwordAuthSuccess {
            passwordText.value = .success
            self.password = password
        } else {
            passwordText.value = .wrongFormat
        }
    }
    
    func setPasswordConfirmationText(_ passwordRepeat: String) {
        if passwordRepeat == passwordResult {
            passwordRepeatText.value = .success
            passwordAuthSuccess = true
        } else {
            passwordRepeatText.value = .wrongFormat
            passwordAuthSuccess = false
        }
    }
    
    func sendAuthCode(email: String, completion: @escaping (Bool, String?) -> Void) {
        firebaseAuthManager.userLogin(email: "admin@naver.com", password: "admin1!") { [weak self] authError in
            guard let self = self else { return }
            
            if authError == .none {
                self.fireStoreDB.emailCheck(email: email) { emailCheckError in
                    if emailCheckError == .none {
                        completion(false, "유저 정보가 존재합니다. 다른 계정으로 가입해주세요.")
                    } else {
                        self.fireStoreDB.getSMTPInfo { smtpInfo, error in
                            guard let smtpInfo = smtpInfo, error == .none else {
                                completion(false, "SMTP 정보를 가져오는 데 실패했습니다: \(error.description)")
                                return
                            }
                            self.smtpManager.sendAuth(userEmail: email, logoImage: UIImage(named: "logo_poda")?.pngData(), smtpInfo: smtpInfo) { authCode, success in
                                if success {
                                    self.userAuthCode = authCode
                                    completion(true, "인증 코드가 발송되었습니다. 이메일을 확인해 주세요.")
                                } else {
                                    completion(false, "이메일 전송에 실패했습니다.")
                                }
                            }
                        }
                    }
                }
            } else {
                completion(false, "관리자 로그인에 실패했습니다: \(authError.description)")
            }
        }
    }
    
    func onCompleteSingupTapped() {
        
        firebaseAuthManager.signUpUser(email: self.email, password: self.password, profileImage: self.profileImage, nickName: self.nickName) { [weak self] error in
            guard let self = self else { return }
            if error == .none {
                completeSignup.value = .success
            } else {
                completeSignup.value = .error(error.description)
            }
        }
    }
}
