//
//  MoreDiaryVIewModel.swift
//  PODA
//
//  Created by 랑 on 11/6/23.
//

import Foundation
import UIKit

class MoreDiaryViewModel {
    
    var diaryList: [DiaryData] = [] {
        didSet {
            // diaryDataList 데이터가 담겼을 때 didSet 실행
            // diaryDataLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
            diaryDataLoaded(self.diaryList)
        }
    }
    
    var diaryDataLoaded: ([DiaryData]) -> Void = { _ in }
    
    var diaryEmptyState: Bool {
        return diaryList.isEmpty
    }
    
    var diaryCount: Int {
        return diaryList.count
    }
    
    func getDiaryImage(_ index: Int) -> UIImage {
        let diaryList = self.diaryList[index]
        return UIImage(data: diaryList.diaryImageList[0]) ?? UIImage()
    }
    
    func getDiaryName(_ index: Int) -> String {
        let diaryList = self.diaryList[index]
        return diaryList.diaryName
    }
    
    func getDiaryDate(_ index: Int) -> String {
        let diaryList = self.diaryList[index]
        return Date.updateTime(dateTime: diaryList.createDate)
    }
}
