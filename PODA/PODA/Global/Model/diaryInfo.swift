//
//  DiaryInfo.swift
//  PODA
//
//  Created by 박유경 on 2023/10/16.
//


struct DiaryInfo: Codable {
    let deviceName: String
    let diaryName: String
    let createTime: String
    let updateTime: String
    let diaryTitle : String
    let description: String
    let frameRate: String
    let diaryDetail: DiaryDetail
}

struct DiaryDetail: Codable {
    let totalPage: Int
    let pageInfo: [PageInfo]
}

struct PageInfo: Codable {
    let page: Int
    let backgroundColor: String
    let componentInfo: ComponentInfo
}

struct ComponentInfo: Codable {
    let image: [ImageInfo]
    let sticker: [StickerInfo]
    let label: [LabelInfo]
}

struct ImageInfo: Codable {
    let step: Int
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let angle: Double
    let name: String
    let xScale : Double
    let yScale : Double
}

struct StickerInfo: Codable {
    let step: Int
    let type: Int
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let angle: Double
    var xScale : Double
    var yScale : Double
}

struct LabelInfo: Codable {
    let step: Int
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let angle: Double
    let fontsize: Double
    let fontname: String
    let fontcolor: String
    var xScale : Double
    var yScale : Double
}
