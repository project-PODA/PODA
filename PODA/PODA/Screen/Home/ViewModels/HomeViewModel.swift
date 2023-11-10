//
//  HomeViewModel.swift
//  PODA
//
//  Created by 랑 on 11/6/23.
//

// viewModel = 뷰를 위한 (데이터) 모델로써,  1.모델(데이터)와 2.로직을 가짐. (뷰와 뷰모델이 나뉘면 로직만 가지고 테스트 코드 작성 가능함)
// MVVM 에서는 뷰와 뷰모델이 1:1 매칭이 될 필요가 없음. 3뷰에 1뷰모델 일 수 도 있음. 나처럼 데이터 하나를 여러 뷰에서 같이 쓸 때!

import Foundation
import UIKit

/*
 데이터가 변할 때마다 뷰모델 > 뷰로 전달 / 데이터가 변하면 그거에 따라서 뷰도 변경된다 (뷰가 변경되는 방법을 어떻게 깔끔하게 전달하느냐가 중요)
 */

class HomeViewModel {
    
    private let firebaseDBManager: FirestorageDBManager
    private let firebaseImageManager: FireStorageImageManager
    
    // 핵심 데이터(모델)
    var diaryList: [DiaryData] = [] {
        didSet {
            // diaryDataList 데이터가 담겼을 때 didSet 실행
            // diaryDataLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
            diaryDataLoaded(self.diaryList)
        }
    }
    
    var diaryDataLoaded: ([DiaryData]) -> Void = { _ in }
    //var diaryEmptyState: ((Bool) -> Void)?
    
    var diaryEmptyState: Bool {
        return diaryList.isEmpty
    }
    
    var diaryCountInt: Int {
        return diaryList.count
    }
    
    // 핵심 데이터(모델)
    var pieceList: [ImageMemory] = [] {
        didSet {
            // pieceList 데이터가 담겼을 때 didSet 실행
            // pieceListLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
            pieceListLoaded(self.pieceList)
        }
    }
    // loadedWithError
    var pieceListLoaded: ([ImageMemory]) -> Void = { _ in }
    //var pieceEmptyState: ((Bool) -> Void)?
    
    var pieceEmptyState: Bool {
        return pieceList.isEmpty
    }
    
    var pieceCountState: Bool {
        return pieceCountInt < 6
    }
    
    var selectedOrderOptionState: ((Bool) -> Void)?
    // var sortedPieceListState: ((Int) -> Void)?
    
    var pieceCountInt: Int {
        return pieceList.count
    }
    
    var sortedList : [ImageMemory] {
        if isSortedByPieceDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            return pieceList.sorted(by: { dateFormatter.string(from: $0.memoryDate ?? Date()) > dateFormatter.string(from: $1.memoryDate ?? Date()) })
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            return pieceList.sorted(by: { dateFormatter.string(from: $0.createDate ?? Date()) > dateFormatter.string(from: $1.createDate ?? Date()) })
        }
        
    }
    
    var sortedListbyPieceDate: [ImageMemory] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return pieceList.sorted(by: { dateFormatter.string(from: $0.memoryDate ?? Date()) > dateFormatter.string(from: $1.memoryDate ?? Date()) })
    }
    
    var sortedListbyCreateDate: [ImageMemory] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return pieceList.sorted(by: { dateFormatter.string(from: $0.createDate ?? Date()) > dateFormatter.string(from: $1.createDate ?? Date()) })
    }
    
    var randomPieceIndex: Int?
    var isSortedByPieceDate = true
    
    init(firebaseDBManager: FirestorageDBManager, firebaseImageManager: FireStorageImageManager) {
        self.firebaseDBManager = firebaseDBManager
        self.firebaseImageManager = firebaseImageManager
        // self.pieceList = [] > 위에서 빈 배열로 선언하지 않는 경우 여기서 이렇게 초기화할 수도 있음
    }
    
//    func getSortedPieceList(with date: Date) -> Array<Any> {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy.MM.dd"
//        return pieceList.sorted(by: { dateFormatter.string(from: $0.date ?? Date()) > dateFormatter.string(from: $1.date ?? Date()) })
//    }
    
    func loadDiaryData() {
        firebaseDBManager.getDiaryDocuments { [weak self] diaryNameList, error in
            guard let self else { return }
            if error == .none {
                if diaryNameList.count == 1 {
                    // account라는 document 하나는 default로 있으므로 dairyList.count == 1 이면 추가된 다이어리는 0이라는 의미
                    //diaryEmptyState?(true)
                    diaryList = []
                } else {
                    for diaryName in diaryNameList {
                        if diaryName != "account" {
                            let diaryInfoList = getDiaryList(diaryName)
                            getDiaryImage(diaryInfoList)
                            print("diaryInfoList: \(diaryInfoList)")
                        }
                    }
                    print("diaryList: \(diaryList)")
                    diaryList.sort { $0.createDate > $1.createDate }
                    //diaryEmptyState?(false)
                }
            }
        }
    }
    
    func getDiaryList(_ diaryName: String) -> [DiaryInfo] {
        var list: [DiaryInfo] = []
        firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { diaryInfoList, error in
            if error == .none {
                for diaryInfo in diaryInfoList {
                    list.append(diaryInfo)
                    print("1번 \(list)")
                }
            }
        }
        print("2번 \(list)")
        return list
    }
    
    func getDiaryImage(_ diaryInfoList: [DiaryInfo]) {
        guard let diaryInfo = diaryInfoList.first else { return }
        firebaseImageManager.getDiaryImage(dinaryName: diaryInfo.diaryName) { [weak self] error, imageList in
            guard let self = self else { return }
            if error == .none {
                self.diaryList.append(DiaryData(
                    pageDataList: diaryInfoList[0].diaryDetail?.pageInfo ?? [],
                    diaryName: diaryInfo.diaryName,
                    diaryImageList: imageList,
                    createDate: diaryInfo.createTime,
                    ratio: Ratio(rawValue: diaryInfo.frameRate) ?? .square,
                    description: diaryInfo.description)
                )
            }
        }
    }
    
    func getDiaryData(_ index: Int) -> DiaryData {
        let diaryDataList = self.diaryList[index]
        return diaryDataList
    }
    
    func getDiaryName(_ index: Int) -> String {
        let diaryDataList = self.diaryList[index]
        return diaryDataList.diaryName
    }
    
    func loadPieceData() {
        pieceList = RealmManager.shared.loadImageMemories().map { $0 }
        randomPieceIndex = pieceList.count != 0 ? Int.random(in: 0..<pieceList.count) : nil
    }
    
    func getPieceImageFromRealm(with pieceInfo: ImageMemory) -> UIImage {
        guard let fileName = pieceInfo.imagePath,
              let documentDirectory = RealmManager.shared.getDocumentDirectory() else { return UIImage() }
        
        let filePath = documentDirectory.appendingPathComponent(fileName).path
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            print("이미지 로딩 실패: \(error.localizedDescription)")
        }
        return UIImage()
    }
    
    func getPieceDate(with pieceInfo: ImageMemory) -> String {
        guard let pieceDate = pieceInfo.memoryDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: pieceDate)
    }
    
    func didTapPieceDateOrderButton() {
        isSortedByPieceDate = true
        selectedOrderOptionState?(true)
    }
    
    func didTapCreateDateOrderButton() {
        isSortedByPieceDate = false
        selectedOrderOptionState?(false)
    }
    
    func getPieceImage(_ index: Int, _ isSortedByPieceDate: Bool) -> UIImage {
        if isSortedByPieceDate {
            let pieceInfo = self.sortedListbyPieceDate[index]
            return getPieceImageFromRealm(with: pieceInfo)
        } else {
            let pieceInfo = self.sortedListbyCreateDate[index]
            return getPieceImageFromRealm(with: pieceInfo)
        }
    }
    
//    func updateUI() {
//        guard let pieceCount = pieceList?.count else { return }
//        
//        if pieceCount != 0 {
//            pieceCountLabel.isHidden = false
//            emptyMorePieceLabel.isHidden = true
//            pieceDateOrderButton.isHidden = false
//            createDateOrderButton.isHidden = false
//            pieceAlbumCollectionView.isHidden = false
//            self.pieceCountLabel.setUpLabel(title: "총 \(pieceCount)개", podaFont: .body1)
//            
//            if pieceCount < 6 {
//                bubbleImageView.isHidden = false
//                infoLabel.isHidden = false
//            } else {
//                bubbleImageView.isHidden = true
//                infoLabel.isHidden = true
//            }
//        } else {
//            pieceCountLabel.isHidden = true
//            emptyMorePieceLabel.isHidden = false
//            pieceDateOrderButton.isHidden = true
//            createDateOrderButton.isHidden = true
//            pieceAlbumCollectionView.isHidden = true
//        }
//    }
}

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
