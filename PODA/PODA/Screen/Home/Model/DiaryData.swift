//
//  DiaryData.swift
//  PODA
//
//  Created by 랑 on 11/7/23.
//

import Foundation

// 뷰를 위한 데이터 (OutPut)
struct DiaryData: Equatable {
    var pageDataList: [PageInfo]
    var diaryName: String
    var diaryImageList: [Data]
    var createDate: String
    var ratio: Ratio
    var description: String
    
    static func == (lhs: DiaryData, rhs: DiaryData) -> Bool {
//        return lhs == rhs
        return lhs.diaryName == rhs.diaryName
    }
}

// >> 얘네를 뷰모델(뷰를 위한 데이터) 로 만들기
