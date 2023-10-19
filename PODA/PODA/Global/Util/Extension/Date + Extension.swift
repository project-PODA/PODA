//
//  Date + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import Foundation

extension Date {
    
    init?(dateString: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: dateString) {
            self = date
        } else {
            return nil
        }
    }
    
    func GetCurrentTime(Dataforamt: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Dataforamt
        let dateString = formatter.string(from: self)
        return dateString
    }
}

