//
//  UserDefaultManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults
    
    var wrappedValue: T {
        get { self.storage.object(forKey: self.key) as? T ?? self.defaultValue }
        set { self.storage.set(newValue, forKey: self.key) }
    }
    
    init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
}

struct UserDefaultManager {
    @UserDefault(key: "isUserLoggedIn", defaultValue: false)
    static var isUserLoggedIn: Bool
    
    @UserDefault(key: "userEmail", defaultValue: "")
    static var userEmail: String
    
    @UserDefault(key: "userPassword", defaultValue: "")
    static var userPassword: String
    
    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    static var hasCompletedOnboarding: Bool
}

