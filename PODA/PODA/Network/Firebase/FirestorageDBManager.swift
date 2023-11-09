//
//  FirestorageDBManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//


import Firebase
import FirebaseStorage

class FirestorageDBManager {
    private let db = Firestore.firestore()
    
    func createDiary(deviceName: String, pageDataList: [PageInfo]?, title: String, description: String, frameRate: Ratio, completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        //밑에껀 더미데이터.
        let diaryInfo = DiaryInfo(
            deviceName: deviceName,
            diaryName: title,
            createTime: Date().getCurrentTime(),
            updateTime: "",
            diaryTitle: title,
            description: description,
            frameRate: frameRate.toString()
//            diaryDetail: DiaryDetail(
//                pageInfo : pageDataList
//            )
        )
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document(title)
            
            documentRef.setData(["diaryInfo" : diaryInfo.toJson()]) { error in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                }else{
                    completion(.none)
                }
            }
        }
    }
    
    func emailCheck(email: String, completion: @escaping (FireStorageDBError) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        let query = db.collection("USER").whereField("email", isEqualTo: email)
        DispatchQueue.global(qos:.userInteractive).async{
            query.getDocuments() { (querySnapshot, error) in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, "Error getting documents"))
                    return
                } else {
                    if querySnapshot!.documents.isEmpty {
                        completion(.documentEmpty)
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    func createUserAccount(userInfo: UserInfo, completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {return}
            
            let batch = db.batch()
            
            let userCollectionRef = db.collection("USER")
            let userDocumentRef = userCollectionRef.document(currentUserUID)
            batch.setData(["email": userInfo.email], forDocument: userDocumentRef)
            
            let currentUserCollectionRef = db.collection(currentUserUID)
            let accountDocumentRef = currentUserCollectionRef.document("account")
            batch.setData(["accountInfo": userInfo.toJson()], forDocument: accountDocumentRef)
            
            batch.commit { error in
                if let err = error {
                    Logger.writeLog(.error, message: "[\(err._code)] : \(err.localizedDescription)")
                    completion(.error(err._code, err.localizedDescription))
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func getDiaryDocuments(completion: @escaping ([String], FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion([],.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            let collectionRef = db.collection(currentUserUID)
            
            collectionRef.getDocuments { (querySnapshot, error) in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion([], .error(errCode.code, errCode.localizedDescription))
                }else{
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
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion([],.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        var diaryInfoList = [DiaryInfo]()
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {return}
            
            for diaryName in diaryNameList {
                dispatchGroup.enter()
                
                let collectionRef = db.collection(currentUserUID)
                let documentRef = collectionRef.document(diaryName)
                
                documentRef.getDocument { (document, error) in
                    if let errCode = error as NSError? {
                        Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                        completion([], .error(errCode.code, errCode.localizedDescription))
                        dispatchGroup.leave()
                        return
                    } else {
                        if let document = document {
                            if let diaryInfoDataString = document["diaryInfo"] as? String {
                                if let diaryInfo = DiaryInfo.fromJson(jsonString: diaryInfoDataString, model: DiaryInfo.self) {
                                    diaryInfoList.append(diaryInfo)
                                } else {
                                    completion([], .error(FireStorageDBError.decodingError.code, FireStorageDBError.decodingError.description))
                                    Logger.writeLog(.error, message: FireStorageDBError.decodingError.description)
                                }
                            }
                        }else{
                            completion([], .error(FireStorageDBError.documentEmpty.code, FireStorageDBError.documentEmpty.description))
                            Logger.writeLog(.error, message: FireStorageDBError.documentEmpty.description)
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
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document(diaryName)
            documentRef.delete { error in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                    return
                }  else {
                    completion(.none)
                }
            }
        }
    }
    
    func updateNickname(updateName: String, completion: @escaping(FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {return}

            let collectionRef = db.collection(currentUserUID)
            let docRef = collectionRef.document("account")

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let json = document.data()?["accountInfo"] as? String

                    var model = UserInfo.fromJson(jsonString: json!, model: UserInfo.self)
                    model?.userNickname = updateName

                    docRef.setData(["accountInfo" : model.toJson()]) { error in
                        if let errCode = error as NSError?{
                            Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                            completion(.error(errCode.code, errCode.localizedDescription))
                            return
                        } else {
                            completion(.none)
                            return
                        }
                    }
                } else {
                    Logger.writeLog(.error, message: FireStorageDBError.documentEmpty.description)
                    completion(.error(FireStorageDBError.documentEmpty.code, FireStorageDBError.documentEmpty.description))
                    return
                }
            }
        }
    }
    
    func deleteDiaryAll(completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            let collectionRef = db.collection(currentUserUID)
            
            collectionRef.getDocuments { (querySnapshot, error) in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    if self.isDiaryPath(refDocPath: document.reference.path, accountPath: currentUserUID + "/account") {
                        document.reference.delete { error in
                            if let errCode = error as NSError?{
                                completion(.error(errCode.code, errCode.localizedDescription))
                                Logger.writeLog(.error, message: (errCode.description))
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
    func getUserNickname(completion: @escaping (String, FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion("", .error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document("account")
            
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let diaryInfoDataString = data?["accountInfo"] as? String {
                        if let userInfo = UserInfo.fromJson(jsonString: diaryInfoDataString, model: UserInfo.self) {
                            let nickname = userInfo.userNickname
                            completion(nickname, .none)
                        } else {
                            completion("", .error(FireStorageDBError.decodingError.code, FireStorageDBError.decodingError.description))
                            Logger.writeLog(.error, message: FireStorageDBError.decodingError.description)
                        }
                    } else {
                        completion("", .error(FireStorageDBError.fieldEmpty.code, FireStorageDBError.fieldEmpty.description))
                        Logger.writeLog(.error, message: FireStorageDBError.fieldEmpty.description)
                    }
                } else {
                    completion("", .error(FireStorageDBError.documentEmpty.code, FireStorageDBError.documentEmpty.description))
                    Logger.writeLog(.error, message: FireStorageDBError.documentEmpty.description)
                }
            }
        }
    }

    func deleteUserMail (completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            let userCollection = db.collection("USER")
            
            userCollection.document(currentUserUID).delete { error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                    return
                    
                } else {
                    completion(.none)
                    return
                }
            }
        }
    }
    
    func deleteCollection(collection: String, completion: @escaping (FireStorageDBError) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        let batch = db.batch()

        db.collection(collection).getDocuments { (snapshot, error) in
            if let errCode = error as NSError?{
                Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                completion(.error(errCode.code, errCode.description))
                return
            } else {
                guard let snapshot = snapshot else {
                    completion(.unknown)
                    return
                }
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { (batchError) in
                    if let batchErrCode = batchError as NSError? {
                        Logger.writeLog(.error, message: "[\(batchErrCode.description)] : \(batchErrCode.description)")
                        completion(.error(batchErrCode.code, batchErrCode.localizedDescription))
                        return
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    func getNotices(completion: @escaping ([NoticeInfo],FireStorageDBError) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            let error = FireStorageDBError.unavailableUUID
            Logger.writeLog(.error, message: "[\(error.code)] : \(error.description)")
            completion([], .error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        let collectionRef = db.collection("Notice")
        var noitceInfoList: [NoticeInfo] = []
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let errCode = error as NSError?{
                
                Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.description)")
                completion([], .error(errCode.code, errCode.description))
            } else {
                for document in querySnapshot!.documents {
                    if let noticeInfoJson = document["noticeInfo"] as? String {
                        if let noticeInfo = NoticeInfo.fromJson(jsonString: noticeInfoJson, model: NoticeInfo.self){
                            noitceInfoList.append(noticeInfo)
                        }else {
                            completion([], .error(FireStorageDBError.fieldEmpty.code, FireStorageDBError.fieldEmpty.description))
                            Logger.writeLog(.error, message: FireStorageDBError.fieldEmpty.description)
                            return
                        }
                    }
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let sortedNoticeInfoArray = noitceInfoList.sorted { (noticeInfo1, noticeInfo2) -> Bool in
                if let date1 = dateFormatter.date(from: noticeInfo1.date), let date2 = dateFormatter.date(from: noticeInfo2.date) {
                    return date1 > date2
                } else {
                    return false 
                }
            }
            completion(sortedNoticeInfoArray, .none)
        }
        
    }
    func isDiaryPath(refDocPath: String, accountPath: String) -> Bool {
        return refDocPath == accountPath ? false : true
    }
}

