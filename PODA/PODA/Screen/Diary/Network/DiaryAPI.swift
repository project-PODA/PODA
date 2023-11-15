//
//  DiaryAPI.swift
//  PODA
//
//  Created by 배은서 on 11/7/23.
//

import Foundation
import UIKit

final class DiaryAPI {
    
    enum NetworkSuccess {
        case createDiary
        case diaryImage
    }
    
    static let shared = DiaryAPI()
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    private init() {}
    
    func postDiary(diary: DiaryData, completion: @escaping ((Result<NetworkSuccess, NetworkError>) -> ()) ) {
        firebaseDBManager.createDiary(
            deviceName: UIDevice.current.name, 
            pageDataList: nil,
            title: diary.diaryName,
            description: diary.description,
            frameRate: diary.ratio) { [weak self] error in
                guard let self = self else { return }
                
                if error == .none {
                    completion(.success(.createDiary))
                    let imageData = diary.pageDataList[0].imageData
                    
                    firebaseImageManager.createDiaryImage(diaryName: diary.diaryName, pageImage: imageData) { error in
                        if error == .none {
                            completion(.success(.diaryImage))
                        } else {
                            completion(.failure(.createDiary))
                        }
                    }
                } else {
                    completion(.failure(.createDiary))
                }
            }
    }
}
