//
//  RealmManager.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import RealmSwift
import UIKit
import FirebaseAuth

class RealmManager {
    static let shared = RealmManager(fireAuthManager: FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator())))
    
    private let fireAuthManager: FireAuthManager
    
    private init(fireAuthManager: FireAuthManager) {
        self.fireAuthManager = fireAuthManager
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
    func savePieceData(image: UIImage?, pieceDate: Date?) {
        guard let imageData = image?.pngData(),
              let documentDirectory = getDocumentDirectory() else {
            print("이미지 또는 Document 디렉토리를 가져오는데 실패했습니다.")
            return
        }
        
        guard let selectedDate = pieceDate else {
            print("경고: 날짜 변환 실패")
            return
        }
        
        guard let userId = fireAuthManager.getCurrentUserId() else {
            print("사용자 ID를 가져오는 데 실패했습니다.")
            return
        }
        
        let fileName = "\(UUID().uuidString).png"
        let filePath = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath)
            let realmPieceData = RealmPieceData()
            realmPieceData.id = UUID()
            realmPieceData.userId = userId
            realmPieceData.imagePath = fileName
            realmPieceData.pieceDate = selectedDate
            realmPieceData.createDate = Date()
            
            try realm.write {
                realm.add(realmPieceData)
                print("저장 성공: \(realmPieceData)")
            }
        } catch {
            print("이미지를 저장하거나 Realm에 데이터를 저장하는 데 문제가 발생: \(error.localizedDescription)")
        }
    }
    
    // Realm 데이터 로드 함수
    func loadPieceData() -> Results<RealmPieceData> {
        guard let userId = fireAuthManager.getCurrentUserId() else {
            print("사용자 ID를 가져오는 데 실패했습니다.")
            return realm.objects(RealmPieceData.self)
        }
        
        return realm.objects(RealmPieceData.self).filter("userId == %@", userId)
    }
    
    // Realm 데이터 삭제 함수
    func deletePieceData(_ pieceInfo: RealmPieceData) {
        do {
            try realm.write {
                realm.delete(pieceInfo)
                print("Realm에서 이미지 메모리 삭제 성공")
            }
        } catch {
            print("Realm에서 이미지 메모리 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func updatePieceDate(_ pieceInfo: RealmPieceData, _ date: Date) {
        do {
            try realm.write {
                pieceInfo.pieceDate = date
                print("Realm에서 날짜 업데이트 성공")
            }
        } catch {
            print("Realm에서 날짜 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // userId에 저장된 로컬 데이터 삭제 함수
    func deleteLocalUserData() {
        guard let userId = fireAuthManager.getCurrentUserId() else {
            print("로컬 데이터를 삭제 중 사용자 ID를 가져오는 데 실패")
            return
        }
        
        let objectsToDelete = realm.objects(RealmPieceData.self).filter("userId == %@", userId)
        
        do {
            try realm.write {
                realm.delete(objectsToDelete)
                print("유저 로컬 데이터 삭제 성공")
            }
        } catch {
            print("유저 로컬 데이터 삭제 실패: \(error.localizedDescription)")
        }
    }
}
