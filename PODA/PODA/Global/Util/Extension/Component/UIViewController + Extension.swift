//
//  UIViewController + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithTextField(title: String, message: String, placeholder: String, defaultValue: String? = nil, completion: @escaping (String?) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = defaultValue
        }
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text else {
                completion(nil)
                return
            }
            completion(text)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completion(nil)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
