//
//  DetailViewModel.swift
//  PODA
//
//  Created by 랑 on 11/10/23.
//

import Foundation
import UIKit

class DetailViewModel {
    
    var diaryData: DiaryData?
    
    func getDiaryImage() -> UIImage {
        return UIImage(data: diaryData?.diaryImageList[0] ?? Data()) ?? UIImage()
    }
    
    func getDiaryName() -> String {
        return diaryData?.diaryName ?? ""
    }
    
    func getDiaryDate() -> String {
        return Date.updateTime(dateTime: diaryData?.createDate ?? "")
    }
    
    func getDiaryContent() -> String {
        return diaryData?.description ?? ""
    }
}
