//
//  FirestorageDBManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth
import Firebase
import FirebaseStorage

class FirestorageDBManager{
    private var db = Firestore.firestore()
    
    func createDiary(deviceName : String , pageDataList : [PageInfo], title : String, description : String, frameRate : FrameRate, backgroundColor : String,completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
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
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document(title)
            
            documentRef.setData(["diaryInfo" : diaryInfo.toJson()
            ]) { error in
                if let error = error {
                    completion(.unknown)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                }else{
                    completion(.none)
                }
            }
        }
    }
    func createUser(userInfo : UserInfo, completion: @escaping (FireStorageDBError) -> Void){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document("/account")
            
            documentRef.setData(["accountInfo" : userInfo.toJson()]) { error in
                if let error = error {
                    completion(.unknown)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                }else{
                    completion(.none)
                }
            }
        }
        
    }
    
    func getDiaryDocuments(completion: @escaping ([String], FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            let collectionRef = db.collection(currentUserUID)
            
            collectionRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion([], .unknown)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                } else {
                    var documentNames = [String]()
                    for document in querySnapshot!.documents {
                        documentNames.append(document.documentID)
                    }
                    completion(documentNames, .none)
                }
            }
        }
    }
    
    func getDiaryData(diaryNameList: [String], completion: @escaping ([DiaryInfo], FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        var diaryInfoList = [DiaryInfo]()
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {return}
            
            for diaryName in diaryNameList {
                dispatchGroup.enter()
                
                let collectionRef = db.collection(currentUserUID)
                let documentRef = collectionRef.document(diaryName)
                
                documentRef.getDocument { (document, error) in
                    if let error = error {
                        completion([], .unknown)
                        Logger.writeLog(.error, message: (error.localizedDescription))
                        dispatchGroup.leave()
                    } else {
                        if let document = document {
                            if let diaryInfoDataString = document["diaryInfo"] as? String {
                                if let diaryInfo = DiaryInfo.fromJson(jsonString: diaryInfoDataString, model: DiaryInfo.self) {
                                    diaryInfoList.append(diaryInfo)
                                } else {
                                    completion([], .invalidData)
                                    Logger.writeLog(.error, message: "json decoding error")
                                }
                            }
                        }else{
                            completion([], .unknown)
                            Logger.writeLog(.error, message: "document is null")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(diaryInfoList, .none)
            }
        }
    }

    func deleteDiary(diaryName: String, completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document(diaryName)
            documentRef.delete { error in
                if let error = error {
                    completion(.unknown)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func deleteDiaryAll(completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let collectionRef = db.collection(currentUserUID)

            collectionRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.unknown)
                    Logger.writeLog(.error, message: (error.localizedDescription))
                    return
                }
                let dispatchGroup = DispatchGroup()
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    if self.isDiaryPath(refDocPath: document.reference.path, accountPath: currentUserUID + "/account") {
                        document.reference.delete { error in
                            if let error = error {
                                completion(.unknown)
                                Logger.writeLog(.error, message: (error.localizedDescription))
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(.none)
                }
            }
        }
    }
    
    func isDiaryPath(refDocPath: String, accountPath: String) -> Bool {
        return refDocPath == accountPath ? false : true
    }
}
