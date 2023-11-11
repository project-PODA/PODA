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
    
    var isSortedByPieceDate = true
    
    var pieceListLoaded: ([PieceData]) -> Void = { _ in }
    
    var selectedOrderOptionState: ((Bool) -> Void)?
    
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
        return pieceList[index].pieceDate
    }
    
    func getPieceImage(_ index: Int) -> UIImage {
        return pieceList[index].image
    }
    
    func didTapPieceDateOrderButton() {
        isSortedByPieceDate = true
        selectedOrderOptionState?(true)
    }
    
    func didTapCreateDateOrderButton() {
        isSortedByPieceDate = false
        selectedOrderOptionState?(false)
    }
}
