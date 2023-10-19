//
//  Decodable + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import Foundation

extension Decodable {
    static func fromJson(jsonString: String, model: Self.Type) -> Self? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            let instance = try decoder.decode(Self.self, from: jsonData)
            return instance
        } catch {
            print(error.localizedDescription)
            Logger.writeLog(.error, message: error.localizedDescription)
            return nil
        }
    }
}
