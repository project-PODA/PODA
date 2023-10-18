//
//  FirestorageDBManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth
import Firebase
import FirebaseStorage

class FireStoreDBManager{
    private var db = Firestore.firestore()
    
    func createDiary(deviceName : String , pageDataList : [PageInfo], title : String, description : String, frameRate : FrameRate, backgroundColor : String,completion: @escaping (FireStorageDBError?) -> Void) {
        
        //밑에껀 더미데이터.
        let diaryInfo = DiaryInfo(
            deviceName: deviceName,
            diaryName: title,
            createTime: Date().GetCurrentTime(),
            updateTime: "",
            diaryTitle: title,
            description: description,
            frameRate: frameRate.toString(),
            diaryDetail: DiaryDetail(
                totalPage: pageDataList.count,
                pageInfo : pageDataList
            )
        )
        print(diaryInfo.toJson())
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(Auth.auth().currentUser!.uid)
            let documentRef = collectionRef.document(title)
            
            documentRef.setData(["diaryInfo" : diaryInfo.toJson()
            ]) { error in
                if let error = error {
                    completion(.invalidURL)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                }else{
                    completion(nil)
                }
            }
        }
    }
    
    func getDiaryDocuments(completion: @escaping ([String]?, FireStorageDBError?) -> Void) {
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            let collectionRef = db.collection(Auth.auth().currentUser!.uid)
            
            collectionRef.getDocuments { (querySnapshot, err) in
                if let _ = err {
                    completion(nil, .none)
                } else {
                    var documentNames = [String]()
                    for document in querySnapshot!.documents {
                        documentNames.append(document.documentID)
                    }
                    completion(documentNames, nil)
                }
            }
        }
    }
    
    func deleteDiary(diaryName: String, completion: @escaping (FireStorageDBError?) -> Void) {
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(Auth.auth().currentUser!.uid)
            let documentRef = collectionRef.document(diaryName)
            documentRef.delete { error in
                if let _ = error {
                    completion(.none)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    //Async/Await으로 쓸거면 아래함수에서.
    @available(iOS 13, *)
    func createDiaryInfoAsync(deviceName: String, pageImageList: [Data], pageDataList : [PageInfo], title: String, description: String, frameRate: FrameRate, backgroundColor: String) async {
        let collectionRef = db.collection(Auth.auth().currentUser!.uid)
        let documentRef = collectionRef.document(title)
        
        let diaryInfo = DiaryInfo(
            deviceName: deviceName,
            diaryName: title,
            createTime: Date().GetCurrentTime(),
            updateTime: "",
            diaryTitle: title,
            description: description,
            frameRate: frameRate.toString(),
            diaryDetail: DiaryDetail(
                totalPage: pageImageList.count,
                pageInfo : pageDataList
            )
        )
        
        do {
            try await documentRef.setData([
                "diaryInfo": diaryInfo.toJson()
            ])
        } catch {
            if let networkError = error as? FireStorageDBError {
                Logger.writeLog(.error, message: "\(networkError.localizedDescription)")
            } else {
                print("업로드 성공")
            }
        }
    }
    
    @available(iOS 13, *)
    func getDiaryDocumentList() async -> [String]{
        let collectionRef = db.collection(Auth.auth().currentUser!.uid)
        
        do {
            let querySnapshot = try await collectionRef.getDocuments()
            var documentNames = [String]()
            for document in querySnapshot.documents {
                documentNames.append(document.documentID)
            }
            return documentNames
        } catch {
            
            if let networkError = error as? FireStorageDBError {
                Logger.writeLog(.error, message: "\(networkError.localizedDescription)")
            }
            return []
        }
    }
    @available(iOS 13, *)
    func deleteDiaryAsync(diaryName: String) async {
        let collectionRef = db.collection(Auth.auth().currentUser!.uid)
        let documentRef = collectionRef.document(diaryName)
        do {
            try await documentRef.delete()
        } catch {
            if let networkError = error as? FireStorageDBError {
                Logger.writeLog(.error, message: "\(networkError.localizedDescription)")
            }
        }
    }
}
