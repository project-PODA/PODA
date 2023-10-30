//
//  String + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/30.
//

import Foundation

extension String {
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
