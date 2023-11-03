//
//  RealmManager.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import RealmSwift
import UIKit

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
    
    //    // Realm 데이터 저장 함수
    //    func saveImageMemory(imagePath: String?, memoryDate: Date?) {
    //        let imageMemory = ImageMemory()
    //        imageMemory.imagePath = imagePath
    //        imageMemory.memoryDate = memoryDate
    //
    //        do {
    //            try realm.write {
    //                realm.add(imageMemory)
    //                print("저장 성공: \(imageMemory)")
    //            }
    //        } catch {
    //            print("Realm에 데이터를 저장하는 데 문제가 발생: \(error.localizedDescription)")
    //        }
    //    }
    
    // Document 디렉토리의 경로를 얻는 함수
    func getDocumentDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    // 이미지를 Document 디렉토리에 저장하고, 그 경로를 Realm에 저장하는 함수
    func saveImageMemory(image: UIImage?, memoryDate: Date?) {
        guard let imageData = image?.pngData(),
              let documentDirectory = getDocumentDirectory() else {
            print("이미지 또는 Document 디렉토리를 가져오는데 실패했습니다.")
            return
        }
        
        guard let selectedDate = memoryDate else {
            print("경고: 날짜 변환 실패")
            return
        }
        
        let fileName = "\(UUID().uuidString).png"
        let filePath = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath)
            let imageMemory = ImageMemory()
            imageMemory.imagePath = fileName
            imageMemory.memoryDate = selectedDate
            imageMemory.createDate = Date()
            
            try realm.write {
                realm.add(imageMemory)
                print("저장 성공: \(imageMemory)")
            }
        } catch {
            print("이미지를 저장하거나 Realm에 데이터를 저장하는 데 문제가 발생: \(error.localizedDescription)")
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
                print("Realm에서 이미지 메모리 삭제 성공")
            }
        } catch {
            print("Realm에서 이미지 메모리 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func updatePieceDate(_ imageMemory: ImageMemory, _ date: Date) {
        do {
            try realm.write {
                imageMemory.memoryDate = date
                print("Realm에서 날짜 업데이트 성공")
            }
        } catch {
            print("Realm에서 날짜 업데이트 실패: \(error.localizedDescription)")
        }
    }
}
