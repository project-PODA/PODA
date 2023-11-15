//
//  SMTPInfo.swift
//  PODA
//
//  Created by Kyle on 11/15/23.
//

import Foundation

struct SMTPInfo: Codable {
    let smtpAddress: String
    let email: String
    let password: String
}
