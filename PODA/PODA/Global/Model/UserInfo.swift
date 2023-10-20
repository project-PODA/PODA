//
//  UserInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/10/19.
//

import Foundation
struct UserInfo: Codable {
    let createDate: String
    let loginDate: String
    let isUsing : Bool
    let image : Data?
    let userNickname : String
    let email : String
    let password : String
    let followers : [String]
    let followings : [String]
}
