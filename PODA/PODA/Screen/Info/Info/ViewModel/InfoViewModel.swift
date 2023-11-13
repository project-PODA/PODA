//
//  InfoViewModel.swift
//  PODA
//
//  Created by FUTURE on 11/8/23.
//

import UIKit
import MessageUI
import FirebaseAuth

class InfoViewModel {
    private let fireAuthManager: FireAuthManager
    
    
    init(fireAuthManager: FireAuthManager) {
        self.fireAuthManager = fireAuthManager
    }
    
    let items: [String] = ["버전", "개인정보처리방침", "서비스 이용 약관", "공지사항", "기능 추가 요청/오류 신고"]
    
    func getItemsCount() -> Int {
        return items.count
    }
    
    func getItemTitle(_ index: Int) -> String {
        return items[index]
    }
    
    // 로그아웃 로직
    func logout(completion: @escaping () -> Void) {
        fireAuthManager.userLogOut { error in
            if error == FireAuthError.none {
                self.clearUserSession()
                completion()
            }
        }
    }
    
    
    func clearUserSession() {
        UserDefaultManager.isUserLoggedIn = false
        UserDefaultManager.userEmail = ""
        UserDefaultManager.userPassword = ""
    }
    
    
    enum SendMailError: Error {
        case appVersionError
        case mailServicesError
    }
    
    //이메일 보내기 로직
    func sendEmail(completion: @escaping (Result<MFMailComposeViewController, SendMailError>) -> Void) {
        
        // App Version
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            completion(.failure(.appVersionError))
            return
        }
        
        // User ID
        let userID = Auth.auth().currentUser?.uid ?? "Unknown"
        
        // 이메일 전송 가능 여부 확인
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.modalPresentationStyle = .overFullScreen
            mailComposeVC.setToRecipients(["poda_official@naver.com"])
            mailComposeVC.setSubject("PODA 문의 사항")
            mailComposeVC.setMessageBody("오류사항 및 문의사항을 세세히 입력해주세요.\n(필요하다면 스크린샷도 함께 첨부해주세요.) \n\n App Version: \(appVersion) \n Device: \(UIDevice.iPhoneModel) \n OS: \(UIDevice.iOSVersion) \n UserID: \(userID)", isHTML: false)
            completion(.success(mailComposeVC))
        } else {
            completion(.failure(.mailServicesError))
        }
    }
}
