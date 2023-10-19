//
//  RealmManager.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    private init() {
        
    }
    
    lazy var realm: Realm = {
        do {
            return try Realm()
        } catch {
            fatalError("Realm 인스턴스를 생성하는데 실패하였습니다: \(error)")
        }
    }()
}
