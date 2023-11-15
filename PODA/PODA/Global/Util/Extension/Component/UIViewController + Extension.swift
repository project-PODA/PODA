//
//  UIViewController + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit
enum AnimationType: String {
    case shake
    func toString() -> String {
        return self.rawValue
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String?, message: String?, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    func showAlertWithTextField(title: String, message: String, placeholder: String, completion: @escaping (String?) -> Void)  {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var confirmAction: UIAlertAction!
        
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        }
        
        confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text else {
                completion(nil)
                return
            }
            if text.count > 5 {
                return
            }
            completion(text)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completion(nil)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func moveToHome() {
        UserDefaultManager.isUserLoggedIn = false
        UserDefaultManager.userEmail = ""
        UserDefaultManager.userPassword = ""
        
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                let loginViewController = LoginViewController(viewModel: LoginViewModel())
                let navigationController = BaseNavigationController(rootViewController: loginViewController)
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        sceneDelegate.window?.rootViewController = navigationController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }, completion: nil)
                }
            }
        }
    }
    
    func makeAnimation(animationType: AnimationType, for textField: UITextField) {
        switch animationType {
        case .shake:
            let shakeAnimation = CABasicAnimation(keyPath: "position")
            shakeAnimation.duration = 0.1
            shakeAnimation.repeatCount = 3
            shakeAnimation.autoreverses = true
            shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 5, y: textField.center.y))
            shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 5, y: textField.center.y))
            textField.layer.add(shakeAnimation, forKey: "position")
        }
    }
    
    @objc private func textChanged(_ textField: UITextField) {
        if let text = textField.text, text.count > 5 {
            textField.textColor = .red
            if let alertController = self.presentedViewController as? UIAlertController {
                alertController.actions[0].isEnabled = false
            }
            makeAnimation(animationType: .shake, for: textField)
        } else {
            if let alertController = self.presentedViewController as? UIAlertController {
                alertController.actions[0].isEnabled = true
            }
            textField.textColor = .black
        }
    }
}
