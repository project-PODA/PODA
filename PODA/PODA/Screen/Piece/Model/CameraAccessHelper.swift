//
//  CameraAccessHelper.swift
//  PODA
//
//  Created by Kyle on 10/26/23.
//

import AVFoundation
import UIKit

class CameraAccessHelper {
    static func requestCameraAccess(presenter: UIViewController, completionHandler: @escaping (Bool) -> ()) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completionHandler(true)
        case .denied, .restricted:
            DispatchQueue.main.async {
                showAlertToSettings(presenter: presenter)
            }
            completionHandler(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (isAuthorized) in
                DispatchQueue.main.async {
                    if isAuthorized {
                        completionHandler(true)
                    } else {
                        showAlertToSettings(presenter: presenter)
                        completionHandler(false)
                    }
                }
            }
        default:
            completionHandler(false)
            break
        }
    }
    
    static func showAlertToSettings(presenter: UIViewController) {
        let alertController = UIAlertController(
            title: "카메라 접근 권한이 필요합니다",
            message: "카메라 접근을 허용하려면 설정에서 권한을 변경해주세요.",
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
