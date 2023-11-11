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
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    var diaryData: DiaryData?
    var isDiaryImage = true
    
    var realmPieceList: [RealmPieceData] = []
    
    var pieceList: [PieceData] = [] {
        didSet {
            // pieceList 데이터가 담겼을 때 didSet 실행
            // pieceListLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
            pieceListLoaded(self.pieceList)
        }
    }
    
    var pieceListLoaded: ([PieceData]) -> Void = { _ in }
    
    var selectedOrderOptionState: ((Bool) -> Void)?
    
    var pieceIndex: Int?
    var isSortedByPieceDate = true
    
    func deleteDiaryData(_ completion: @escaping (() -> ())) {
        guard let diaryName = diaryData?.diaryName else { return }
        firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
            if error == .none {
                self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
                    NotificationCenter.default.post(
                        name: SaveDeleteViewController.deleteDiaryNotificationName,
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
    
    func didTapPieceDateOrderButton() {
        isSortedByPieceDate = true
        selectedOrderOptionState?(true)
    }
    
    func didTapCreateDateOrderButton() {
        isSortedByPieceDate = false
        selectedOrderOptionState?(false)
    }
    
    func deletePieceData(_ index: Int) {
        let targetId = pieceList[index].id
        if let targetIndex = realmPieceList.firstIndex(where: { $0.id == targetId }) {
            print("동일한 id를 가진 객체의 인덱스: \(targetIndex)")
            RealmManager.shared.deleteImageMemory(realmPieceList[targetIndex])
            // FIXME: - 수정하기
            // pieceList.remove(at: index) > notification으로 홈의 pieceList에서 삭제해야함
        } else {
            print("targetId와 일치하는 realmPieceList.id가 없어!!")
        }
    }
}
