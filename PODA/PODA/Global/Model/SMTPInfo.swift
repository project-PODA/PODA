//
//  SMTPInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/11/07.
//

struct SMTPInfo: Codable {
    let sendUserName: String
    let smtpAddress: String
    let email: String
    let password: String
}
