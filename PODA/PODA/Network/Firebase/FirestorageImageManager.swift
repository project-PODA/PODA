//
//  FirestorageImageManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth
import Firebase
import FirebaseStorage

class FireStorageImageManager{
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    private let imageManipulator = ImageManipulator()
    
    func createDiaryImage(diaryName: String, pageImageList: [Data], completion: @escaping (FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            for i in 0..<pageImageList.count {
                let fileName = "image\(i + 1)"
                let format = imageManipulator.checkImageFormat(imageData: pageImageList[i])
                let fileFullName = "\(fileName)_\(format)"
                
                let storageReference = storage.reference()
                let imageReference = storageReference.child("\(currentUserUID)/images/\(diaryName)/\(fileFullName)")
                let metadata = StorageMetadata()
                
                metadata.contentType = format
                
                imageReference.putData(pageImageList[i], metadata: metadata) { (metadata, error) in
                    if let error = error {
                        completion(.uploadFailed)
                        print(error.localizedDescription)
                        Logger.writeLog(.error, message: error.localizedDescription)
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    func getDiaryImage(dinaryName : String , completion: @escaping (FireStorageImageError, [Data]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(.unknown, [])
            return
        }
        
        
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            
            let storageReference = storage.reference()
            let imageReference = storageReference.child("\(currentUserUID)/images/\(dinaryName)")
            
            imageReference.listAll { (result, error) in
                if let error = error {
                    Logger.writeLog(.error, message: error.localizedDescription)
                    completion(.unknown, [])
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
                    item.getData(maxSize: 1024 * 1024) { data, error in
                        if let error = error {
                            completion(.unknown, imageDataList)
                            Logger.writeLog(.error, message: error.localizedDescription)
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
    func createProfileImage(imageData : Data, completion: @escaping (FireStorageImageError) -> Void){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(.unknown)
            return
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let fileName = "profileImage"
            let format = imageManipulator.checkImageFormat(imageData: imageData)
            let fileFullName = "\(fileName)_\(format)"

            let storageReference = storage.reference()
            let imageReference = storageReference.child("\(currentUserUID)/profile/\(fileFullName)")
            let metadata = StorageMetadata()

            metadata.contentType = format

            imageReference.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    completion(.uploadFailed)
                    print(error.localizedDescription)
                    Logger.writeLog(.error, message: error.localizedDescription)
                } else {
                    completion(.none)
                }
            }
        }
    }
    
    func deleteDiaryImage(diaryName: String, completion: @escaping (FireStorageImageError) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(.unknown)
            return
        }
        DispatchQueue.global(qos: .background).async{ [weak self] in
            guard let self = self else {return}
            
            let storageReference = storage.reference()
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
                        if let error = error {
                            print("파일 삭제 실패: \(item.fullPath), \(error.localizedDescription)")
                            Logger.writeLog(.error, message: error.localizedDescription)
                            return
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
}
