//
//  ImageManipulator.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//
import Foundation

struct ImageManipulator{
    func checkImageFormat(imageData: Data) -> String {
        var format: String
        if imageData.starts(with: [0xFF, 0xD8, 0xFF]) {
            format = "jpeg"
        } else if imageData.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            format = "png"
        } else if imageData.starts(with: [0x47, 0x49, 0x46]) {
            format = "gif"
        }else{
            format = "Unsupported Format" // 지원을 안하는 포맷
        }
        return format
    }
    
}
