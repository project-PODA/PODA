//
//  Encodable + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import Foundation

extension Encodable {
    func toJson() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
            Logger.writeLog(.error, message: error.localizedDescription)
        }
        return nil
    }
}
