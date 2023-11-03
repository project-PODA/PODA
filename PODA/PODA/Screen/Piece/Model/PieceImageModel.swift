//
//  PieceImageModel.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import Foundation
import RealmSwift

class ImageMemory: Object {
    @Persisted var imagePath: String?
    @Persisted var memoryDate: Date?
    @Persisted var createDate: Date?
}

