//
//  PieceImageModel.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import Foundation
import RealmSwift

// FIXME: - 마이그레이션!!!! 필수!!!!!!!! 지근님 도움!!!!!!!!!!!
class RealmPieceData: Object {
    @Persisted var id: UUID?
    @Persisted var imagePath: String?
    @Persisted var pieceDate: Date?
    @Persisted var createDate: Date?
}
