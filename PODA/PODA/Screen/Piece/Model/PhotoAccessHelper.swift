//
//  File.swift
//  PODA
//
//  Created by Kyle on 10/26/23.
//

import Photos
import UIKit

class PhotoAccessHelper {
    static func requestPhotoLibraryAccess(presenter: UIViewController, completionHandler: @escaping (Bool) -> ()) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            // 이미 전체 권한이 허용된 경우
            completionHandler(true)
        case .limited:
            // 일부 사진에만 접근 가능한 경우
            completionHandler(true)
        case .denied, .restricted:
            // 권한이 거부되었거나 제한된 경우
            DispatchQueue.main.async {
                showAlertToSettings(presenter: presenter)
            }
            completionHandler(false)
        case .notDetermined:
            // 아직 권한을 요청하지 않은 경우
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (newStatus) in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        completionHandler(true)
                    } else {
                        showAlertToSettings(presenter: presenter)
                        completionHandler(false)
                    }
                }
            }
        @unknown default:
            completionHandler(false)
        }
    }
    
    static func showAlertToSettings(presenter: UIViewController) {
        let alertController = UIAlertController(
            title: "앨범 접근 권한이 필요합니다",
            message: "앨범 접근을 허용하려면 설정에서 권한을 변경해주세요.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (action) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        presenter.present(alertController, animated: true, completion: nil)
    }
}

