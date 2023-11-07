//
//  ProfileViewModel.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

class ProfileViewModel {
    
    var profileImageSetting: ((Data) -> Void)?
    var profileNickNameSetting: ((String) -> Void)?
    var nickNameUpdate: ((String) -> Void)?
    var imageUpdate: (() -> Void)?
    
    private let fireDBManager: FirestorageDBManager
    private let fireImageManager: FireStorageImageManager
    
    init(fireDBManager: FirestorageDBManager, fireImageManager: FireStorageImageManager) {
        self.fireDBManager = fireDBManager
        self.fireImageManager = fireImageManager
    }
    
    //🔫3
    var username: String = "" {
        didSet {
            self.nickNameUpdate?(username)
        }
    }
    
    func resizingImage(image: UIImage) -> UIImage? {
        let newSize = CGSize(width: 300, height: 300 * image.size.height / image.size.width)
        let resizedImage = image.resized(to: newSize)
        return resizedImage
    }
    
    
    func getFirebaseData(){
        fireImageManager.getProfileImage { [weak self] (error, image) in
            guard let self = self else { return }
            
            if error == .none, let imageData = image {
                profileImageSetting?(imageData)
            }
        }
        
        fireDBManager.getUserNickname{[weak self] (name, error) in
            guard let self = self else {return}
            if error == .none {
                profileNickNameSetting?(name)
            }
        }
    }
    
    //🔫2
    func updateNickname(nickname newNickname: String) {
        fireDBManager.updateNickname(updateName: newNickname) { [weak self]  error in
            guard let _ = self else { return }
            print("Update 성공")
            if error == .none {
                self?.username = newNickname
            }
        }
    }
    
    //🥕2
    func updateProfileImage(profileImage newImage: UIImage?) {
        fireImageManager.createProfileImage(imageData: newImage!.pngData()!) { [weak self] (error) in
            guard let self = self else { return }
            if error == .none {
                imageUpdate?()
            }
        }
    }
}
