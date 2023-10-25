//
//  DiaryInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/10/16.
//


struct DiaryInfo: Codable {
    var deviceName: String
    var diaryName: String
    var createTime: String
    var updateTime: String
    var diaryTitle: String
    var description: String
    var frameRate: String
    var diaryDetail: DiaryDetail
}

struct DiaryDetail: Codable {
    var totalPage: Int
    var pageInfo: [PageInfo]
}

struct PageInfo: Codable {
    var page: Int
    var backgroundColor: String
    var componentInfo: ComponentInfo
}

struct ComponentInfo: Codable {
    var image: [ImageInfo]
    var sticker: [StickerInfo]
    var label: [LabelInfo]
}

struct ImageInfo: Codable {
    var step: Int
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var angle: Double
    var name: String
    var xScale: Double
    var yScale: Double
}

struct StickerInfo: Codable {
    var step: Int
    var type: Int
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var angle: Double
    var xScale: Double
    var yScale: Double
}

struct LabelInfo: Codable {
    var step: Int
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var angle: Double
    var fontsize: Double
    var fontname: String
    var fontcolor: String
    var xScale : Double
    var yScale : Double
}
