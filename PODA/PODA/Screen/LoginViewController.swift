//
//  LoginPageViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/16.
//

import UIKit
import Then

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
    
    private let passwordTextField = UITextField().then {
        $0.borderStyle = .none
        $0.isSecureTextEntry = true
    }
    
    private lazy var eyeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "eye"), for: .normal)
        $0.tintColor = .gray
        $0.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
    }
    
    private let loginButton = UIButton().then {
        $0.setUpButton(title: "로그인", podaFont: .button1, cornerRadius: 22)
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private let emailLineView = UIView().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private let passwordLineView = UIView().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
    }
    
    private let signUpButton = UIButton().then {
        $0.setUpButton(title: "회원가입", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        view.addSubview(emailLabel)
        view.addSubview(passwordLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailLineView)
        view.addSubview(passwordTextField)
        view.addSubview(passwordLineView)
        view.addSubview(eyeButton)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        
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
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(loginButton)
            make.width.equalTo(loginButton)
        }
    }
    
    @objc private func eyeButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.fill"
        let image = UIImage(systemName: imageName)
        eyeButton.setImage(image, for: .normal)
    }
}
