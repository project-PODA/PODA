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
    
    func getCurrentTime(Dataforamt: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Dataforamt
        let dateString = formatter.string(from: self)
        return dateString
    }
    
    static func updateTime(dateTime: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String = "yyyy.MM.dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = dateFormatter.date(from: dateTime) {
            let modifiedDateFormatter = DateFormatter()
            modifiedDateFormatter.dateFormat = outputFormat
            return modifiedDateFormatter.string(from: date)
        }
        return ""
    }
}

