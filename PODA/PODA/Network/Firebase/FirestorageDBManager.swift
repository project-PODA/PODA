//
//  FirestorageDBManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//


import Firebase
import FirebaseStorage

class FirestorageDBManager {
    private var db = Firestore.firestore()
    
    func createDiary(deviceName : String , pageDataList : [PageInfo], title : String, description : String, frameRate : FrameRate, backgroundColor : String,completion: @escaping (FireStorageDBError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
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
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {return}
            
            let collectionRef = db.collection(currentUserUID)
            let documentRef = collectionRef.document(title)
            
            documentRef.setData(["diaryInfo" : diaryInfo.toJson()]) { error in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
                }else{
                    print("다이어리 정보 생성 성공")
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
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
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
                print("유저정보 생성 및 계정 성공")
                completion(.none)
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
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
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
                        Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                        completion([], .error(errCode.code, errCode.localizedDescription))
                        dispatchGroup.leave()
                        return
                    } else {
                        if let document = document {
                            if let diaryInfoDataString = document["diaryInfo"] as? String {
                                if let diaryInfo = DiaryInfo.fromJson(jsonString: diaryInfoDataString, model: DiaryInfo.self) {
                                    diaryInfoList.append(diaryInfo)
                                } else {
                                    completion([], .error(9999, "DiaryInfo Decdoing Error"))//좀더 생각해보기
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
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
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
                        if let error = error {
                            print("닉네임 업데이트 실패: \(error)")
                            completion(.unknown)
                            return
                        } else {
                            print("닉네임 업데이트 성공")
                            completion(.none)
                            return
                        }
                    }
                } else {
                    print("해당 문서를 찾을 수 없습니다.")
                    completion(.unknown)
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
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription))
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
    func getUserNickname(completion: @escaping (String, FireStorageDBError) -> Void){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion("", .error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            let collectionRef = db.collection(currentUserUID)
            
            collectionRef.getDocuments { (querySnapshot, error) in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion("", .error(errCode.code, errCode.localizedDescription))
                    return
                }else{
                    if let document = querySnapshot {
                        for doc in document.documents {
                            let data = doc.data()
                            if let diaryInfoDataString = data["accountInfo"] as? String {
                                if let userInfo = UserInfo.fromJson(jsonString: diaryInfoDataString, model: UserInfo.self) {
                                    let nickname = userInfo.userNickname
                                    completion(nickname, .none)
                                    return
                                } else {
                                    completion("", .error(9999, "DiaryInfo Decoding Error"))
                                    Logger.writeLog(.error, message: "JSON decoding error")
                                    return
                                }
                            } else {
                                completion("", .error(9999, "No Account Info"))
                                Logger.writeLog(.error, message: "No account info found")
                                return
                            }
                        }
                    } else {
                        completion("", .unknown)
                        Logger.writeLog(.error, message: "Document is null")
                        return
                    }
                }
            }
        }
    }
    func deleteUserMail (completion: @escaping (FireStorageDBError) -> Void){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageDBError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageDBError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            let db = Firestore.firestore()
            let userCollection = db.collection("USER")
            
            userCollection.document(currentUserUID).delete { error in
                if let errCode = error as NSError?{
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
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
        let db = Firestore.firestore()
        let batch = db.batch()

        db.collection(collection).getDocuments { (snapshot, error) in
            if let errCode = error as NSError?{
                Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                completion(.error(errCode.code, errCode.localizedDescription))
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
                        Logger.writeLog(.error, message: "[\(batchErrCode.code)] : \(batchErrCode.localizedDescription)")
                        completion(.error(batchErrCode.code, batchErrCode.localizedDescription))
                        return
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    
    func isDiaryPath(refDocPath: String, accountPath: String) -> Bool {
        return refDocPath == accountPath ? false : true
    }
}

