//
//  LoginPageViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/16.
//

import UIKit
import Then
import NVActivityIndicatorView

class LoginViewController: BaseViewController, UIConfigurable {
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "logo_poda")
    }
    
    private let emailLabel = UILabel().then {
        $0.setUpLabel(title: "이메일", podaFont: .subhead1)
        $0.textColor = Palette.podaBlue.getColor()
    }
    
    private let passwordLabel = UILabel().then {
        $0.setUpLabel(title: "비밀번호", podaFont: .subhead1)
        $0.textColor = Palette.podaBlue.getColor()
    }
    
    private let emailTextField = UITextField().then {
        $0.borderStyle = .none
    }
    
    private let emailLineView = UIView().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private let passwordTextField = UITextField().then {
        $0.borderStyle = .none
        $0.isSecureTextEntry = true
    }
    
    private let eyeButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_eye"), for: .normal)
        $0.tintColor = .gray
    }
    
    private let passwordLineView = UIView().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private lazy var googleIconButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_google"), for:.normal)
        $0.setImage(UIImage(named: "icon_google"), for:.highlighted)
        $0.layer.cornerRadius = 36
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var appleIconButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_apple"), for:.normal)
        $0.setImage(UIImage(named: "icon_apple"), for:.highlighted)
        $0.layer.cornerRadius = 36
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
    }
    
    private let loginButton = UIButton().then {
        $0.setUpButton(title: "로그인", podaFont: .button1, cornerRadius: 22)
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private let askLabel = UILabel().then {
        $0.setUpLabel(title: "아직 회원이 아니신가요?", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let signUpButton = UIButton().then {
        $0.setUpButton(title: "회원가입", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    private let fireAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    
    private lazy var loadingIndicator = NVActivityIndicatorView(frame: .zero, color: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupActions()
        setupTextFields()
        hideKeyboardWhenTappedAround()
        emailTextField.enableHideKeyboardOnReturn()
        passwordTextField.enableHideKeyboardOnReturn()
    }
    
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpButtonTap), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(goToMain), for: .touchUpInside)
    }
    
    func configUI() {
        
        let subviews: [UIView] = [
            logoImageView, emailLabel, passwordLabel, emailTextField,
            emailLineView, passwordTextField, passwordLineView, eyeButton,
            loginButton, googleIconButton, appleIconButton, askLabel, signUpButton, loadingIndicator
        ]
        
        subviews.forEach { view.addSubview($0) }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(logoImageView.snp.bottom).offset(80)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
        }
        
        emailLineView.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(8)
            make.left.equalTo(emailTextField)
            make.right.equalTo(emailTextField)
            make.height.equalTo(1)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(emailLineView.snp.bottom).offset(25)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.left.equalTo(passwordLabel)
            make.right.equalTo(eyeButton.snp.left).offset(-10)
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.height.equalTo(emailTextField)
        }
        
        passwordLineView.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(8)
            make.left.equalTo(passwordTextField)
            make.right.equalTo(emailLineView)
            make.height.equalTo(1)
        }
        
        eyeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(passwordTextField)
            make.width.height.equalTo(30)
        }
        
        loginButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.top.equalTo(passwordTextField.snp.bottom).offset(60)
            make.height.equalTo(44)
        }
        
        googleIconButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 72, height: 72))
            make.right.equalTo(view.snp.centerX).offset(-8)
        }
        
        appleIconButton.snp.makeConstraints { make in
            make.top.equalTo(googleIconButton)
            make.size.equalTo(googleIconButton)
            make.left.equalTo(view.snp.centerX).offset(8)
        }
        
        askLabel.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(loginButton)
            make.width.equalTo(loginButton)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
    }
    
    @objc private func googleButtonTapped() {
        print("google")
    }
    
    @objc private func appleButtonTapped() {
        print("apple")
    }
    
    
    @objc private func eyeButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        
        let imageName = passwordTextField.isSecureTextEntry ? "icon-eye" : "icon-eye.filled"
        let image = UIImage(named: imageName)
        eyeButton.setImage(image, for: .normal)
    }
    
    @objc private func signUpButtonTap() {
        let signUpVC = SignUpViewController()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func goToMain() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        loadingIndicator.startAnimating()
        setComponentDisable(false)
        fireAuthManager.userLogin(email: email, password: password){ [weak self] error in
            guard let self = self else {return}
            
            if error == .none {
                let tabBarController = BaseTabbarController()
                navigationController!.pushViewController(tabBarController, animated: true)
                
                UserDefaultManager.isUserLoggedIn = true
                UserDefaultManager.userEmail = email
                UserDefaultManager.userPassword = password
                
            } else {
                showAlert(title: "에러", message: "ID와 비밀번호를 확인해주세요.")
            }
            DispatchQueue.main.async{ [weak self] in
                guard let self = self else {return}
                loadingIndicator.stopAnimating()
                setComponentDisable(true)
            }
        }
    }
    
    private func setComponentDisable(_ enabled : Bool){
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        eyeButton.isEnabled = enabled
        googleIconButton.isEnabled = enabled
        appleIconButton.isEnabled = enabled
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func setupTextFields() {
        
        emailTextField.setUpTextField(delegate: self)
        passwordTextField.setUpTextField(delegate: self)
        
        // 왼쪽 패딩값 제거
        emailTextField.leftView = nil
        emailTextField.leftViewMode = .never
        passwordTextField.leftView = nil
        passwordTextField.leftViewMode = .never
    }
}
