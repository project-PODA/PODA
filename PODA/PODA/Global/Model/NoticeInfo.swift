//
//  NoticeInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/10/25.
//

struct NoticeInfo: Codable {
    let title: String
    var date: String
    let content: String
    var isContentVisible: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title, date, content
    }
}
