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

// 이미지 캐싱,, 용량 압축해서 올리는거 고려

class HomeViewModel {
    
    // MARK: - Properties for diary
    private let firebaseAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    private let firebaseDBManager: FirestorageDBManager
    private let firebaseImageManager: FireStorageImageManager
    
    // 핵심 데이터(모델)
    var diaryList: [DiaryData] = [] 
//    {
//        didSet {
//             diaryDataList 데이터가 담겼을 때 didSet 실행
//             diaryDataLoaded() > 클로져를 통해서 데이터가 변한 시점을 전달
//            diaryDataLoaded(self.diaryList)
//        }
//    }
//    
//    var diaryDataLoaded: ([DiaryData]) -> Void = { _ in }
    
    var diaryEmptyState: Bool {
        return diaryList.isEmpty
    }
    
    var diaryCount: Int {
        return diaryList.count
    }
    
    var diaryDataLoaded: (() -> Void)?
    
    var loadingIndicatorState: ((Bool) -> Void)?
    
    // MARK: - Properties for piece
    // 핵심 데이터(모델)
    var realmPieceList: [RealmPieceData] = []

    var pieceList: [PieceData] = []
    
    var sortByLatest = true
    
    var sortedList: [PieceData] {
        if sortByLatest {
            return pieceList.sorted(by: { $0.pieceDate > $1.pieceDate } )
        } else {
            return pieceList.sorted(by: { $0.pieceDate < $1.pieceDate } )
        }
    }
    
    // loadedWithError
    var pieceListLoaded: ([PieceData]) -> Void = { _ in }
    
    var pieceEmptyState: Bool {
        return realmPieceList.isEmpty
    }
    
    var pieceCount: Int {
        return pieceList.count
    }
    
    var pieceCountState: Bool {
        return pieceCount < 6
    }
    
    var latestPieceButtonSelectedState: ((Bool) -> Void)?
     
    var randomPieceIndex: Int?
    
    init(firebaseDBManager: FirestorageDBManager, firebaseImageManager: FireStorageImageManager) {
        self.firebaseDBManager = firebaseDBManager
        self.firebaseImageManager = firebaseImageManager
        // self.pieceList = [] > 위에서 빈 배열로 선언하지 않는 경우 여기서 이렇게 초기화할 수도 있음
    }
    
    func login() {
        firebaseAuthManager.userLogin(email: UserDefaultManager.userEmail, password: UserDefaultManager.userPassword) { [weak self] error in
            guard let _ = self else { return }
        }
    }
    
    // MARK: - Helpers for diary
    func loadDiaryData() {
        loadingIndicatorState?(true)
        
        firebaseDBManager.getDiaryDocuments { [weak self] diaryNameList, error in
            guard let self else { return }
            if error == .none {
                if diaryNameList.count == 1 {
                    // account라는 document 하나는 default로 있으므로 dairyList.count == 1 이면 추가된 다이어리는 0이라는 의미
                    DispatchQueue.main.async {
                        self.loadingIndicatorState?(false)
                    }
                } else {
                    for diaryName in diaryNameList {
                        if diaryName != "account" {
                            firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { diaryInfoList, error in
                                if error == .none, let diaryInfo = diaryInfoList.first {
                                    self.getDiaryImage(diaryInfo, diaryNameList.count - 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
            // FIXME: - async/await 사용해서 이 함수 호출하기
//    func getDiaryList(_ diaryName: String) -> [DiaryInfo] {
//        var list: [DiaryInfo] = []
//        firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { diaryInfoList, error in
//            if error == .none {
//                for diaryInfo in diaryInfoList {
//                    list.append(diaryInfo)
//                    print("1번 \(list)")
//                }
//            }
//        }
//        print("2번 \(list)")
//        return list
//    }
    
    func getDiaryImage(_ diaryInfo: DiaryInfo, _ totalDiaryCount: Int) {
        firebaseImageManager.getDiaryImage(diaryName: diaryInfo.diaryName) { [weak self] error, imageList in
            guard let self = self else { return }
            if error == .none {
                self.diaryList.append(DiaryData(
                    pageDataList: diaryInfo.diaryDetail?.pageInfo ?? [],
                    diaryName: diaryInfo.diaryName,
                    diaryImageList: imageList,
                    createDate: diaryInfo.createTime,
                    ratio: Ratio(rawValue: diaryInfo.frameRate) ?? .square,
                    description: diaryInfo.description)
                )
                // totalDiaryCount는 diaryNameList에서 account라는 document 하나를 뺀 갯수. 즉 유저가 만든 다이어리의 갯수!
                // diaryList 배열에 모든 다이어리가 하나씩 추가되고 나서 UI 업데이트, 로딩바가 멈추도록 if diaryCount == totalDiaryCount 조건을 걸음
                // 이 조건이 없는 경우 diaryList 배열에 하나씩 추가될 때마다 UI가 업데이트 되어 1,2,3,4권 이런식으로 바뀌는게 눈에 보이고 로딩바도 첫번째 데이터를 받아오는 순간 멈춤
                if diaryCount == totalDiaryCount {
                    DispatchQueue.main.async {
                        self.diaryDataLoaded?()
                        self.loadingIndicatorState?(false)
                    }
                }
            }
        }
    }
    
    func sortDiaryList() {
        diaryList.sort { $0.createDate > $1.createDate }
    }
    
    func getDiaryData(_ index: Int) -> DiaryData {
        let diaryDataList = self.diaryList[index]
        return diaryDataList
    }
    
    func getDiaryName(_ index: Int) -> String {
        let diaryDataList = self.diaryList[index]
        return diaryDataList.diaryName
    }
    
    // MARK: - Helpers for piece
    func loadPieceData() {
        realmPieceList = RealmManager.shared.loadPieceData().map { $0 }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        for realmPiece in realmPieceList {
            // FIXME: - 수정
            // pieceList에 추가하려는 id가 없는 경우에만 append > 이렇게 하거나 이 메서드 실행될 때 pieceList를 [] 빈 배열로 초기화 해주기(이렇게 하면 갯수 많아졌을 때 실행될 때마다 모든 piece를 배열에 추가해야하는 단점이 있을 듯)
            if !pieceList.contains(where: { $0.id == realmPiece.id }) {
                let image = getPieceImage(with: realmPiece)
                pieceList.append(PieceData(id: realmPiece.id ?? UUID(), image: image, pieceDate: dateFormatter.string(from: realmPiece.pieceDate ?? Date())))
            }
        }
        randomPieceIndex = pieceList.count != 0 ? Int.random(in: 0..<pieceList.count) : nil
    }
    
    // key: id, image로 두고 딕셔너리 만들어서 넣어두고 거기서 꺼내쓰기 ,,,,,,,
    
    func getPieceImage(with pieceInfo: RealmPieceData) -> UIImage {
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
    
    func didTapLatestPieceButton() {
        sortByLatest = true
        latestPieceButtonSelectedState?(true)
    }
    
    func didTapOldestPieceButton() {
        sortByLatest = false
        latestPieceButtonSelectedState?(false)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCreateNotification), name: DetailDiaryViewController.createDiaryNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteDiaryNotification), name: SaveDeleteViewModel.deleteDiaryNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePieceNotification), name: SaveDeleteViewModel.deletePieceNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModifyPieceDateNotification), name: PieceViewController.modifyPieceDateNotificationName, object: nil)
    }
    
    @objc func handleCreateNotification(_ notification: NSNotification) {
        if let diaryData = notification.object as? DiaryData {
            diaryList.append(diaryData)
        }
    }
    
    @objc func handleDeleteDiaryNotification(_ notification: NSNotification) {
        if let diaryData = notification.object as? DiaryData {
            if let targetIndex = diaryList.firstIndex(of: diaryData) {
                diaryList.remove(at: targetIndex)
            }
        }
    }
    
    @objc func handleDeletePieceNotification(_ notification: NSNotification) {
        if let targetId = notification.object as? UUID {
            if let targetIndex = pieceList.firstIndex(where: { $0.id == targetId } ) {
                pieceList.remove(at: targetIndex)
            }
        }
    }
    
    @objc func handleModifyPieceDateNotification(_ notification: NSNotification) {
        if let (targetId, modifiedDate) = notification.object as? (UUID, String) {
            if let targetIndex = pieceList.firstIndex(where: { $0.id == targetId } ) {
                pieceList[targetIndex].pieceDate.forEach { _ in pieceList[targetIndex].pieceDate = modifiedDate }
            }
        }
    }
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
