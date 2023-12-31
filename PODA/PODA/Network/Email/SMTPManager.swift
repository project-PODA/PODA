//
//  SMTPManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/23.
//

import Foundation
import SwiftSMTP
class SMTPManager {
    
//    private let hostSMTP = SMTP(hostname: "smtp.naver.com", email: "poda_official@naver.com", password: "podapoda17")
    private let htmlParser : HTMLParser
    
    init(htmpParser : HTMLParser) {
        self.htmlParser = htmpParser
    }
    
    func sendAuth(userEmail: String, logoImage: Data?, smtpInfo: SMTPInfo, completion: @escaping (Int, Bool) -> Void) {
        let code = Int.random(in: 10000...99999)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let hostSMTP =  SMTP(hostname: smtpInfo.smtpAddress, email: smtpInfo.email, password: smtpInfo.password)
            let fromUser = Mail.User(email: smtpInfo.email)
            let toUser = Mail.User(email: userEmail)

            if let imageData = logoImage {
                let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
                
                let htmlContent = htmlParser.getSMTPSampleString(email: toUser.email, authCode: code, base64Image: base64String)
                let htmlAttachment = Attachment(htmlContent: htmlContent)
                let mail = Mail(
                    from: fromUser,
                    to: [toUser],
                    subject: "PODA 이메일 인증 안내",
                    text: "",
                    attachments: [htmlAttachment]
                )
                
                hostSMTP.send([mail], completion: { success, fail in
                    if !fail.isEmpty {
                        if let error = (fail.first?.1 as? NSError) {
                            Logger.writeLog(.error, message: "[\(SMTPError.error(error.code, "전송실패"))] : \(error.localizedDescription)")
                            completion(code, false)
                        }
                    } else {
                        completion(code, true)
                        print(code)
                    }
                }
            )} else {
                Logger.writeLog(.error, message: "[\(SMTPError.error(SMTPError.worngFileFormat.code, "전송실패"))] : \(SMTPError.worngFileFormat.description)")
                completion(code, false)
            }
        }
    }
}

