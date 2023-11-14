//
//  PieceImageModel.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import Foundation
import RealmSwift

class RealmPieceData: Object {
    @Persisted var id: UUID?
    @Persisted var userId: String?
    @Persisted var imagePath: String?
    @Persisted var pieceDate: Date?
    @Persisted var createDate: Date?
}
