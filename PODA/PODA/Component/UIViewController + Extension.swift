//
//  UIViewController + Extension.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
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
}
