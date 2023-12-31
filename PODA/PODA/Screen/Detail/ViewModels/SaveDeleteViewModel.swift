//
//  SaveDeleteViewModel.swift
//  PODA
//
//  Created by 랑 on 11/10/23.
//

import Foundation
import RealmSwift
import UIKit

class SaveDeleteViewModel {
    
    static let deleteDiaryNotificationName = NSNotification.Name("deleteDiary")
    static let deletePieceNotificationName = NSNotification.Name("deletePiece")
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    var diaryData: DiaryData?
    var isDiaryImage = true
    
    var realmPieceList: [RealmPieceData] = []
    
    var pieceList: [PieceData] = []
    
    var pieceIndex: Int?
    
    func deleteDiaryData(_ completion: @escaping (() -> ())) {
        guard let diaryName = diaryData?.diaryName else { return }
        firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
            if error == .none {
                self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
                    NotificationCenter.default.post(
                        name: SaveDeleteViewModel.deleteDiaryNotificationName,
                        object: DiaryData(
                            pageDataList: self.diaryData?.pageDataList ?? [],
                            diaryName: diaryName,
                            diaryImageList: self.diaryData?.diaryImageList ?? [],
                            createDate: self.diaryData?.createDate ?? "",
                            ratio: self.diaryData?.ratio ?? .square,
                            description: self.diaryData?.description ?? "")
                    )
                    completion()
                }
            }
        }
    }
    
    func deletePieceData(_ index: Int) {
        let targetId = pieceList[index].id
        if let targetIndex = realmPieceList.firstIndex(where: { $0.id == targetId }) {
            print("동일한 id를 가진 객체의 인덱스: \(targetIndex)")
            RealmManager.shared.deletePieceData(realmPieceList[targetIndex])
            NotificationCenter.default.post(
                name: SaveDeleteViewModel.deletePieceNotificationName,
                object: targetId)
        } else {
            print("targetId와 일치하는 realmPieceList.id가 없어!!")
        }
    }
}
