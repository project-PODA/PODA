//
//  Date + Extension.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
//
import Foundation
extension Date{
    func GetCurrentTime(Dataforamt : String = "yyyy-MM-dd HH:mm:ss") -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = Dataforamt
        let dateString = formatter.string(from: self)
        return dateString
    }
}
