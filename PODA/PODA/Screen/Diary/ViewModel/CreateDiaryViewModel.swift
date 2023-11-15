//
//  CreateDiaryViewModel.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import Foundation
import UIKit

class CreateDiaryViewModel {
    
    var ratio: Observable<Ratio?> = Observable(nil)
    var newImage: Observable<UIImage?> = Observable(nil)
    var diaryName : Observable<String?> = Observable(nil)
    var pageInfo: Observable<[PageInfo]> = Observable([])
    
    var title: Observable<String?> = Observable(nil)
    var content: Observable<String> = Observable("")
    
    var titleTextCount = Observable(0)
    var contentTextCount = Observable(0)
    
    func setDiaryName(_ name: String) {
        diaryName.value = name
    }
    
    func setPageInfo(_ pageInfoList: [PageInfo]) {
        pageInfo.value = pageInfoList
    }
    
    func setTitle(_ text: String) {
        title.value = text
    }
    
    func setContent(_ text: String) {
        content.value = text
    }
    
    func getPageInfo() -> [PageInfo] {
        return pageInfo.value
    }
    
    func getRatio() -> Ratio? {
        return ratio.value
    }
    
    func getDiaryData() -> DiaryData {
        return DiaryData(
            pageDataList: pageInfo.value,
            diaryName: title.value ?? "",
            diaryImageList: [pageInfo.value[0].imageData],
            createDate: Date().getCurrentTime(),
            ratio: ratio.value ?? .square,
            description: content.value)
    }
    
    func handleSquareButton() {
        ratio.value = .square
    }
    
    func handleRectangleButton() {
        ratio.value = .rectangle
    }
    
    func handleNewImage(_ image: UIImage) {
        newImage.value = image
    }
    
    func handleTitleTextCount(_ textCount: Int) {
        titleTextCount.value = textCount
        if textCount > 12 {
            titleTextCount.value = 12
        }
    }
    
    func handleContentTextCount(_ textCount: Int) {
        contentTextCount.value = textCount
        if textCount > 100 {
            contentTextCount.value = 100
        }
    }
    
    func isTitleEmpty(_ title: String?) -> Bool {
        guard let title = title else { return false }
        
        // 입력된 텍스트가 공백으로만 이루어져 있는지 확인
        let isWhiteSpace = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return isWhiteSpace
    }
    
    func handleSaveButton(_ completion: @escaping (() -> ())) {
        DiaryAPI.shared.postDiary(diary: getDiaryData()) { result in
            switch result {
            case .success(let success):
                switch success {
                case .createDiary:
                    print("⭐️ 다이어리 생성 성공")
                case .diaryImage:
                    print("⭐️ 다이어리 이미지 생성 성공")
                }
                
                completion()
            case .failure(let failure):
                switch failure {
                case .createDiary:
                    print("❌ 다이어리 생성 실패")
                case .diaryImage:
                    print("❌ 다이어리 이미지 생성 실패")
                default: break
                }
            }
        }
    }
    
//    func handleNextButton(fromCurrentViewController: UIViewController, alertViewController: UIAlertController) {
//        if let ratio = ratio.value {
//            let viewController = CreateDiaryViewController(viewModel: self, ratio: ratio)
//            fromCurrentViewController.navigationController?.pushViewController(viewController, animated: true)
//        } else {
//            fromCurrentViewController.present(alertViewController, animated: true)
//        }
//    }
}
