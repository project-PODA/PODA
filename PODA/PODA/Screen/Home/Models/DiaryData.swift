//
//  DiaryData.swift
//  PODA
//
//  Created by 랑 on 11/7/23.
//

import Foundation

// UI에 보여질 데이터순.
struct DiaryData: Equatable {
    var diaryName: String
    var diaryImageList: [Data]
    var createDate: String
    var ratio: String
    var description: String
}

// >> 얘네를 뷰모델(뷰를 위한 데이터) 로 만들기
