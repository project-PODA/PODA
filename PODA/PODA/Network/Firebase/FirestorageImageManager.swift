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
    
    func createDiaryImage(diaryTitle: String, pageImageList: [Data], completion: @escaping (FireStorageImageError?) -> Void) {
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
                let imageReference = storageReference.child("\(currentUserUID)/\(diaryTitle)/\(fileFullName)")
                let metadata = StorageMetadata()

                metadata.contentType = format

                imageReference.putData(pageImageList[i], metadata: metadata) { (metadata, error) in
                    if let error = error {
                        completion(.uploadFailed)
                        print(error.localizedDescription)
                        Logger.writeLog(.error, message: error.localizedDescription)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getDiaryImage(dinaryName : String , completion: @escaping (FireStorageImageError?, [Data]?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(.unknown, [])
            return
        }
        let storageReference = storage.reference()
        let imageReference = storageReference.child("\(currentUserUID)/\(dinaryName)")

        imageReference.listAll { (result, error) in
            if let _ = error {
                completion(.unknown, [])
                return
            }
            
            guard let result = result else {
                completion(.unknown, [])
                return
            }
            
            var imageDataList = [Data]()
            let dispatchGroup = DispatchGroup()

            for item in result.items {
                dispatchGroup.enter()
                item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading data: \(error)")
                    } else if let data = data {
                        imageDataList.append(data)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .global(qos: .background)) {
                completion(nil, imageDataList)
            }
        }
    }
    
    func deleteDiaryImage(diaryName: String, completion: @escaping (FireStorageImageError?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let storageReference = storage.reference()
        let imageReference = storageReference.child("\(currentUserUID)/\(diaryName)")

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
                        
                        print("Error deleting image: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(nil)
            }
        }
    }
    
    @available(iOS 13, *)
    func createDiaryImageAsync(diaryTitle: String, pageImageList: [Data]) async {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        for i in 0..<pageImageList.count {
                let fileName = "image\(i)"
                let format = imageManipulator.checkImageFormat(imageData: pageImageList[i])
                let fileFullName = "\(fileName)_\(format)"
                
                let storageReference = storage.reference()
                let imageReference = storageReference.child("\(currentUserUID)/\(fileFullName)")
                let metadata = StorageMetadata()
                
                metadata.contentType = format
                
                do {
                    let data = try await imageReference.putDataAsync(pageImageList[i], metadata: metadata)
                    print("이미지 업로드 성공")
                } catch {
                    print("이미지 업로드 실패: \(error)")
                    Logger.writeLog(.error, message: error.localizedDescription)
                }
            }
    }

    @available(iOS 13, *)
    func getDiaryImageAllAsync() async throws -> [Data?] {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            throw NetworkError.invalidURL
        }
        
        let storageRef = storage.reference()
        let diaryImageRef = storageRef.child(currentUserUID)
        
        do {
            let result = try await diaryImageRef.listAll()
            var imageDataList = [Data?]()
            let dispatchGroup = DispatchGroup()
            
            for item in result.items {
                dispatchGroup.enter()
                item.getData(maxSize: 1 * 1024 * 1024){data, error in   // 비동기 지원 X
                    if let error = error {
                        print("Error downloading data: \(error)")
                    } else if let data = data {
                        imageDataList.append(data)
                    }
                }
                dispatchGroup.leave()
            }
            return imageDataList
        } catch {
            print("Error: \(error)")
            throw NetworkError.invalidData
        }
    }
}
