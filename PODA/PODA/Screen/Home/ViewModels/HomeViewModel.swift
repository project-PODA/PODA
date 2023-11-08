//
//  HomeViewModel.swift
//  PODA
//
//  Created by 랑 on 11/6/23.
//

// viewModel = 뷰를 위한 (데이터) 모델로써,  .1모델(데이터)와 2.로직을 가짐. (뷰와 뷰모델이 나뉘면 로직만 가지고 테스트 코드 작성 가능함)
// MVVM 에서는 뷰와 뷰모델이 1:1 매칭이 될 필요가 없음. 3뷰에 1뷰모델 일 수 도 있음. 나처럼 데이터 하나를 여러 뷰에서 같이 쓸 때!

import Foundation
import UIKit
import RealmSwift

/*

 데이터가 변할 때마다 뷰모델 > 뷰로 전달 / 데이터가 변하면 그거에 따라서 뷰도 변경된다 (뷰가 변경되는 방법을 어떻게 깔끔하게 전닳하느냐가 중요)
 */

class HomeViewModel {
    
    // 핵심 데이터(모델)
    //    var pieceList: Results<ImageMemory>? {
    //        didSet {
    //            // pieceList 데이터가 담겼을 때 didSet 실행
    //            // onCompleted() > 클로져를 통해서 데이터가 변한 시점을 전달
    //        }
    //    }
    
    //    var onCompleted: () -> () {
    //    }
    
    private let firebaseDBManager: FirestorageDBManager
    private let firebaseImageManager: FireStorageImageManager
    
    private var diaryDataList: [DiaryData] {
        didSet {
            // diaryDataList 데이터가 담겼을 때 didSet 실행
            // onCompleted() > 클로져를 통해서 데이터가 변한 시점을 전달
            diaryDataLoaded(self.diaryDataList)
        }
    }
    
    var diaryDataLoaded: ([DiaryData]) -> Void = { _ in }
    
    var updateDiaryCollectionView: ((Bool) -> Void)?
    
    var diaryCountInt: Int {
        return diaryDataList.count
    }
    
    init(firebaseDBManager: FirestorageDBManager, firebaseImageManager: FireStorageImageManager, diaryDataList: [DiaryData]) {
        self.firebaseDBManager = firebaseDBManager
        self.firebaseImageManager = firebaseImageManager
        self.diaryDataList = diaryDataList
    }
    
    func loadDiaryDataFromFirebase() {
        firebaseDBManager.getDiaryDocuments { [weak self] diaryList, error in
            guard let self = self else { return }
            
            if error == .none {
                // FIXME: - counter 변수 확인
                var counter = 0
                if diaryList.count == 1 {
                    // account라는 document 하나는 default로 있으므로 dairyList.count == 1 이면 추가된 다이어리는 0이라는 의미
                    updateDiaryCollectionView?(true)
                }
                for diaryName in diaryList {
                    if diaryName != "account" {
                        firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { [weak self] diaryInfoList, error in
                            guard let self = self else { return }
                            if error == .none, let diaryInfo = diaryInfoList.first {
                                firebaseImageManager.getDiaryImage(dinaryName: diaryInfo.diaryName) { [weak self] error, imageList in
                                    guard let self = self else { return }
                                    if error == .none {
                                        self.diaryDataList.append(DiaryData(
                                            diaryName: diaryInfo.diaryName,
                                            diaryImageList: imageList,
                                            createDate: diaryInfo.createTime,
                                            ratio: diaryInfo.frameRate,
                                            description: diaryInfo.description)
                                        )
                                        counter += 1
                                        if counter == diaryList.count - 1 {
                                            diaryDataList.sort { $0.createDate > $1.createDate }
                                            updateDiaryCollectionView?(false)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// 뷰를 위한 데이터 (OutPut)
//    var diaryName: String?
//    var diaryImageList: [Data]?
//    var createDate: String?
//    var ratio: String?
//    var description: String?


/*
 웬만한 로직들을 여기에 두기
 viewModel.pieceList?.pieceImage  >  얘도 로직이라고 보고 이걸 viewModel에 적기
 
 // Input 데이터를 변하게 하기 위한 로직
 // var pieceImage -> UIImage() {
 
 //}
 }
 
 
 */



// Input 메서드 (사용자의 인풋을 뷰 > 뷰모델로 전달해줌 예: 버튼 눌리는거)
//    func handleAddButtonTapped() {
//        //뷰에서 이 버튼이 눌린걸 전달받고 눌렸을 때 실행할 거 여기에 적기
//        //만약 여기에서 어떤 함수가 필요하면 아래에 적어주기 예: func fetchData()
//
//    }
//
//    // Logic
//    func fetchData() {
//
//    }
//
//}
