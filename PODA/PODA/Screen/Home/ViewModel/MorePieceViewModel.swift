//
//  MorePieceViewModel.swift
//  PODA
//
//  Created by 랑 on 11/10/23.
//

import Foundation
import UIKit

class MorePieceViewModel {
    
    var realmPieceList: [RealmPieceData] = []
    
    var pieceList: [PieceData] = [] {
        didSet {
            // pieceList 데이터가 담겼을 때 didSet 실행
            // pieceListLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
            pieceListLoaded(self.pieceList)
        }
    }
    
    var sortByLatest = true
    
    var sortedList: [PieceData] {
        if sortByLatest {
            return pieceList.sorted(by: { $0.pieceDate > $1.pieceDate } )
        } else {
            return pieceList.sorted(by: { $0.pieceDate < $1.pieceDate } )
        }
    }
    
    var pieceListLoaded: ([PieceData]) -> Void = { _ in }
    
    var latestPieceButtonSelectedState: ((Bool) -> Void)?
    
    var pieceCount: Int {
        return pieceList.count
    }
    
    var pieceEmptyState: Bool {
        return pieceList.isEmpty
    }
    
    var pieceCountState: Bool {
        return pieceCount < 6
    }
    
    func getPieceDate(_ index: Int) -> String {
        return sortedList[index].pieceDate
    }
    
    func getPieceImage(_ index: Int) -> UIImage {
        return sortedList[index].image
    }
    
    func didTapLatestPieceButton() {
        sortByLatest = true
        latestPieceButtonSelectedState?(true)
    }
    
    func didTapOldestPieceButton() {
        sortByLatest = false
        latestPieceButtonSelectedState?(false)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModifyPieceDateNotification), name: PieceViewController.modifyPieceDateNotificationName, object: nil)
    }
    
    @objc func handleModifyPieceDateNotification(_ notification: NSNotification) {
        if let (targetId, modifiedDate) = notification.object as? (UUID, String) {
            if let targetIndex = pieceList.firstIndex(where: { $0.id == targetId } ) {
                pieceList[targetIndex].pieceDate.forEach { _ in pieceList[targetIndex].pieceDate = modifiedDate }
            }
        }
    }
}
