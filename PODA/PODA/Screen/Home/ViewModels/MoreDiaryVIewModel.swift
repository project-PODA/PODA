//
//  MoreDiaryVIewModel.swift
//  PODA
//
//  Created by 랑 on 11/6/23.
//

import Foundation
import UIKit

class MoreDiaryViewModel {
    
    var diaryList: [DiaryData] = []
    
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
