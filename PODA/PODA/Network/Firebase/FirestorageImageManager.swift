//
//  FirestorageImageManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//


import Firebase
import FirebaseStorage

//최대 10메가만 저장.
class FireStorageImageManager {
    private let imageManipulator : ImageManipulator
    private let storageReference = Storage.storage().reference()
    
    init(imageManipulator : ImageManipulator){
        self.imageManipulator = imageManipulator
    }
    
    func createDiaryImage(diaryName: String, pageImage: Data, completion: @escaping (FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            getDiaryImageCount(diaryName: diaryName){ [weak self] error, diaryImageCount in
                guard let self = self else {return}
                
                let fileName = "image" + (diaryImageCount == 0 ? "" : String(diaryImageCount))
                let format = imageManipulator.checkImageFormat(imageData: pageImage)
                let fileFullName = "\(fileName).\(format)"
                
                let imageReference = storageReference.child("\(currentUserUID)/images/\(diaryName)/\(fileFullName)")
                let metadata = StorageMetadata()
                
                metadata.contentType = format
                
                imageReference.putData(pageImage, metadata: metadata) { (metadata, error) in
                    if let errCode = error as NSError?{
                        completion(.error(errCode.code, errCode.localizedDescription))
                        Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    func getDiaryImageCount(diaryName: String, completion:@escaping (FireStorageImageError, Int) -> Void ) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description), -1)
            return
        }
        
        let imagesRef = storageReference.child("\(currentUserUID)/images/\(diaryName)")

         imagesRef.listAll { (result, error) in
             if let error = error {
                 if let errorCode = StorageErrorCode(rawValue: error._code) {
                     if errorCode == .objectNotFound {
                         completion(.unknown, 0)
                         print("0")
                     } else {
                         completion(.unknown, 0)
                         print("0")
                     }
                 } else {
                     completion(.unknown, 0)
                     print("0")
                 }
             } else {
                 let count = result?.items.count
                 completion(.none, count!)
                 print(count!)
             }
         }
        
    }
    
    
    func getDiaryImage(dinaryName: String, completion: @escaping (FireStorageImageError, [Data]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description),[])
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            
            let imageReference = storageReference.child("\(currentUserUID)/images/\(dinaryName)")
            
            imageReference.listAll { (result, error) in
                if let errCode = error as NSError? {
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                    completion(.error(errCode.code, errCode.localizedDescription),[])
                    return
                }
                
                guard let result = result else {
                    Logger.writeLog(.error, message: "StorageListResult is empty")
                    completion(.unknown, [])
                    return
                }
                
                var imageDataList = [Data]()
                let dispatchGroup = DispatchGroup()
                
                for item in result.items {
                    dispatchGroup.enter()
                    item.getData(maxSize: 10 * 1024 * 1024) { data, error in
                        if let errCode = error as NSError? {
                            Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                            completion(.error(errCode.code, errCode.localizedDescription),[])
                            return
                        } else if let data = data {
                            imageDataList.append(data)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .global(qos: .background)) {
                    completion(.none, imageDataList)
                }
            }
        }
    }

    func createProfileImage(imageData: Data, completion: @escaping (FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            let fileName = "profileImage"
            let format = imageManipulator.checkImageFormat(imageData: imageData)
            let fileFullName = "\(fileName)"
            
            let imageReference = storageReference.child("\(currentUserUID)/profile/\(fileFullName)")
            let metadata = StorageMetadata()
            
            metadata.contentType = format
            
            imageReference.putData(imageData, metadata: metadata) { (metadata, error) in
                if let errCode = error as NSError?{
                    completion(.error(errCode.code, errCode.localizedDescription))
                    Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func deleteDiaryImage(diaryName: String, completion: @escaping (FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            
            let imageReference = storageReference.child("\(currentUserUID)/images/\(diaryName)")
            
            imageReference.listAll { (result, error) in
                if let _ = error {
                    completion(.unknown)
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                for item in result!.items {
                    dispatchGroup.enter()
                    item.delete { error in
                        if let errCode = error as NSError?{
                            completion(.error(errCode.code, errCode.localizedDescription))
                            Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(.none)
                }
            }
        }
    }
    
    func getProfileImage(completion: @escaping(FireStorageImageError, Data?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description),nil)
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{ [weak self] in
            guard let self = self else {return}
            
            let imageReference = storageReference.child("\(currentUserUID)/profile/profileImage")

            imageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let errCode = error as NSError?  {
                    completion(.error(errCode.code, error!.localizedDescription), nil)
                } else {
                    if let imageData = data {
                        completion(.none, imageData)
                    }
                }
            }
        }
    }
    
    func deleteFolderContents(reference: StorageReference, completion: @escaping (Error?) -> Void) {
        reference.listAll { (result, error) in
            if let error = error {
                completion(error)
            } else {
                let dispatchGroup = DispatchGroup()
                for item in result!.items {
                    dispatchGroup.enter()
                    item.delete { error in
                        if let error = error {
                            print("Error deleting file: \(error.localizedDescription)")
                        } else {
                            print("File deleted successfully.")
                        }
                        dispatchGroup.leave()
                    }
                }
                for prefix in result!.prefixes {
                    dispatchGroup.enter()
                    self.deleteFolderContents(reference: prefix) { error in
                        if let error = error {
                            completion(error)
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(nil)
                }
            }
        }
    }

    func deleteTopFolder(completion: @escaping(FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }
        
        let topLevelFolderRef = storageReference.child(currentUserUID)

        deleteFolderContents(reference: topLevelFolderRef) { error in
            if let errCode = error as NSError?{
                Logger.writeLog(.error, message: "[\(errCode.code)] : \(errCode.localizedDescription)")
                completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            } else {
                topLevelFolderRef.delete { error in
                    if let error = error {
                        completion(.none)//여기서 에러떨어지는 이유가 몰겠네
                    } else {
                        completion(.none)
                    }
                }
            }
        }

    }

    func updateProfileImage(imageData: Data, completion: @escaping(FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            Logger.writeLog(.error, message: "[\(FireStorageDBError.unavailableUUID.code)] : \(FireStorageImageError.unavailableUUID.description)")
            completion(.error(FireStorageDBError.unavailableUUID.code, FireStorageImageError.unavailableUUID.description))
            return
        }
        
        let imageReference = storageReference.child("\(currentUserUID)/profile/profileImage")

        imageReference.putData(imageData) { metadata, error in
            if let err = error as NSError? {
                completion(.error(err.code, err.localizedDescription))
            } else {
                completion(.none)
            }
        }
    }
}
