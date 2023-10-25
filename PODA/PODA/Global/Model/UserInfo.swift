//
//  UserInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/10/19.
//

import Foundation
struct UserInfo: Codable {
    let createDate: String
    var loginDate: String
    var isUsing : Bool
    var userNickname : String
    let email : String
    var followers : [String]
    var followings : [String]
}
