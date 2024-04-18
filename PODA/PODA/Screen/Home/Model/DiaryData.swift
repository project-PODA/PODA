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
    
    // FIXME: - diaryName으로 비교하고 있어서 이름이 동일한 다이어리가 있는 경우에는 위험,, 다른 비교 방법 찾기. uuid 추가?
    static func == (lhs: DiaryData, rhs: DiaryData) -> Bool {
//        return lhs == rhs
        return lhs.diaryName == rhs.diaryName
    }
}

// >> 얘네를 뷰모델(뷰를 위한 데이터) 로 만들기
