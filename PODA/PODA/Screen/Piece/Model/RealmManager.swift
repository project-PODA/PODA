//
//  RealmManager.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import RealmSwift
import Foundation

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
    
    // Realm 데이터 저장 함수
    func saveImageMemory(imagePath: String?, memoryDate: Date?) {
        let imageMemory = ImageMemory()
        imageMemory.imagePath = imagePath
        imageMemory.memoryDate = memoryDate
        
        do {
            try realm.write {
                realm.add(imageMemory)
                print("저장 성공: \(imageMemory)")
            }
        } catch {
            print("Realm에 데이터를 저장하는 데 문제가 발생: \(error.localizedDescription)")
        }
    }
    
    // Realm 데이터 로드 함수
    func loadImageMemories() -> Results<ImageMemory> {
        return realm.objects(ImageMemory.self)
    }
    
    // Realm 데이터 삭제 함수
    func deleteImageMemory(_ imageMemory: ImageMemory) {
        do {
            try realm.write {
                realm.delete(imageMemory)
            }
        } catch {
            print("Realm에서 이미지 메모리 삭제 실패: \(error.localizedDescription)")
        }
    }
}
