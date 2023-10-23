//
//  SignUpViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/17.
//

import UIKit
import Then
import SnapKit

class SignUpViewController: BaseViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let font = UIFont.podaFont(.display1)
        
        let attributedString = NSAttributedString(string: "사용하실 이메일과 \n비밀번호를 알려주세요", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font
        ])
        
        $0.attributedText = attributedString
    }
    
    
    private let emailLabel = UILabel().then {
        $0.setUpLabel(title: "이메일", podaFont: .subhead2)
    }
    
    private let emailTextField = UITextField().then {
        $0.placeholder = "  ex. poda123@gmail.com"
        $0.borderStyle = .none
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
    }
    
    
    private let emailDeleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_delete"), for: .normal)
        return button
    }()
    
    private let emailErrorLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = true
        $0.setUpLabel(title: "이메일 형식을 확인해주세요.", podaFont: .caption)
    }
    
    private let emailSendButton = UIButton().then {
        $0.setUpButton(title: "메일발송", podaFont: .button1, cornerRadius: 5)
        $0.backgroundColor = Palette.podaGray4.getColor()
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
    }
    
    private let verificationCodeLabel = UILabel().then {
        $0.setUpLabel(title: "인증코드", podaFont: .subhead2)
    }
    
    private let verificationCodeDetailLabel = UILabel().then {
        $0.setUpLabel(title: "메일로 발송된 인증 코드를 복사해 입력해주세요.", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let verificationCodeTextField = UITextField().then {
        $0.placeholder = "  인증코드 입력"
        $0.borderStyle = .none
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
    }
    
    private let verificationCodeDeleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_delete"), for: .normal)
        return button
    }()
    
    private let verifyCodeButton = UIButton().then {
        $0.setUpButton(title: "인증하기", podaFont: .button1, cornerRadius: 5)
        $0.backgroundColor = Palette.podaGray4.getColor()
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
    }
    
    private let passwordLabel = UILabel().then {
        $0.setUpLabel(title: "비밀번호", podaFont: .subhead2)
        
    }
    
    private let passwordDetailLabel = UILabel().then {
        $0.setUpLabel(title: "영문, 숫자, 특수문자 중 2가지 이상을 조합하여 6-15자로 입력해주세요", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let passwordTextField = UITextField().then {
        $0.placeholder = "  비밀번호 입력"
        $0.borderStyle = .none
        $0.isSecureTextEntry = true
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
    }
    
    private let passwordErrorLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = true
        $0.setUpLabel(title: "양식을 지켜 다시 입력해주세요.", podaFont: .caption)
    }
    
    private let passwordEyeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_eye"), for: .normal)
        return button
    }()
    
    
    private let passwordConfirmationLabel = UILabel().then {
        $0.setUpLabel(title: "비밀번호 확인", podaFont: .subhead2)
    }
    
    private let passwordConfirmationTextField = UITextField().then {
        $0.placeholder = "  비밀번호 다시 입력"
        $0.borderStyle = .none
        $0.isSecureTextEntry = true
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
    }
    
    private let confirmPasswordEyeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_eye"), for: .normal)
        return button
    }()
    
    
    private let confirmPasswordErrorLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = true
        $0.setUpLabel(title: "비밀번호가 일치하지 않습니다.", podaFont: .caption)
    }
    
    
    
    private let signUpButton = UIButton().then {
        $0.setUpButton(title: "가입하기", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        addKeyboardObservers()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActions()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        removeKeyboardObservers()
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let pattern = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{6,15}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: password)
    }
    
    private func setActions() {
        passwordEyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        confirmPasswordEyeButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility(_:)), for: .touchUpInside)
        emailDeleteButton.addTarget(self, action: #selector(clearEmailField(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        verificationCodeDeleteButton.addTarget(self, action: #selector(clearVerificationCodeField(_:)), for: .touchUpInside)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        passwordConfirmationTextField.addTarget(self, action: #selector(passwordConfirmationTextFieldDidChange(_:)), for: .editingChanged)
        signUpButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
        
        
    }
    
    private func setupUI() {
        
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [emailLabel, emailTextField, emailDeleteButton, emailErrorLabel, emailSendButton, verificationCodeLabel, verificationCodeDetailLabel, verificationCodeTextField, verificationCodeDeleteButton, verifyCodeButton, passwordLabel, passwordTextField, passwordDetailLabel, passwordEyeButton, passwordErrorLabel, passwordConfirmationLabel, passwordConfirmationTextField, confirmPasswordEyeButton, confirmPasswordErrorLabel].forEach { contentView.addSubview($0) }
        view.addSubview(signUpButton)
        
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(passwordConfirmationTextField.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(contentView.snp.top).offset(30)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.right.equalTo(emailSendButton.snp.left).offset(-5)
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        
        
        emailDeleteButton.snp.makeConstraints { make in
            make.right.equalTo(emailSendButton.snp.left).offset(-5)
            make.centerY.equalTo(emailTextField)
            make.width.height.equalTo(36)
        }
        
        emailErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.left.equalTo(emailLabel)
        }
        
        emailSendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(emailTextField)
            make.width.equalTo(80)
            make.height.equalTo(emailTextField)
        }
        
        verificationCodeLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(emailTextField.snp.bottom).offset(50)
        }
        
        verificationCodeDetailLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(verificationCodeLabel.snp.bottom).offset(4)
        }
        
        verificationCodeTextField.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.right.equalTo(verifyCodeButton.snp.left).offset(-4)
            make.top.equalTo(verificationCodeDetailLabel.snp.bottom).offset(10)
            make.height.equalTo(emailTextField)
        }
        
        verificationCodeDeleteButton.snp.makeConstraints { make in
            make.right.equalTo(verifyCodeButton.snp.left).offset(-5)
            make.centerY.equalTo(verificationCodeTextField)
            make.width.height.equalTo(36)
        }
        
        verifyCodeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(verificationCodeTextField)
            make.width.equalTo(80)
            make.height.equalTo(emailTextField)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(50)
        }
        
        passwordDetailLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(passwordLabel.snp.bottom).offset(4)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(passwordDetailLabel.snp.bottom).offset(10)
            make.height.equalTo(emailTextField)
        }
        
        passwordEyeButton.snp.makeConstraints { make in
            make.right.equalTo(passwordTextField).offset(-5)
            make.centerY.equalTo(passwordTextField)
            make.width.height.equalTo(24)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
            make.left.equalTo(emailLabel)
        }
        
        passwordConfirmationLabel.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
        }
        
        passwordConfirmationTextField.snp.makeConstraints { make in
            make.left.equalTo(emailLabel)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(passwordConfirmationLabel.snp.bottom).offset(10)
            make.height.equalTo(emailTextField)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        confirmPasswordEyeButton.snp.makeConstraints { make in
            make.right.equalTo(passwordConfirmationTextField).offset(-5)
            make.centerY.equalTo(passwordConfirmationTextField)
            make.width.height.equalTo(24)
        }
        
        confirmPasswordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmationTextField.snp.bottom).offset(4)
            make.left.equalTo(emailLabel)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }

    
    @objc private func clearEmailField(_ sender: UIButton) {
        emailTextField.text = ""
    }
    
    
    @objc private func clearVerificationCodeField(_ sender: UIButton) {
        verificationCodeTextField.text = ""
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        emailErrorLabel.isHidden = isValidEmail(email)
    }
    
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "icon_eye" : "icon_eye.filled"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        passwordConfirmationTextField.isSecureTextEntry.toggle()
        let imageName = passwordConfirmationTextField.isSecureTextEntry ? "icon_eye" : "icon_eye.filled"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = view.frame
        aRect.size.height -= keyboardSize.height
        
        if let activeTextField = view.firstResponder as? UITextField, !aRect.contains(activeTextField.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func passwordTextFieldDidChange(_ textField: UITextField) {
        guard let password = textField.text else { return }
        passwordErrorLabel.isHidden = isValidPassword(password)
    }
    
    @objc private func passwordConfirmationTextFieldDidChange(_ textField: UITextField) {
        guard let originalPassword = passwordTextField.text,
              let confirmPassword = textField.text else { return }
        confirmPasswordErrorLabel.isHidden = originalPassword == confirmPassword
    }
    
    @objc private func nextButtonTap() {
        let setProfileVC = SetProfileViewController()
        self.navigationController?.pushViewController(setProfileVC, animated: true)
    }
    
    
    
    
    //💥deinit 추가!! dismiss추가
}

extension UIView {
    var firstResponder: UIView? {
        if self.isFirstResponder {
            return self
        }
        for subView in subviews {
            if let responder = subView.firstResponder {
                return responder
            }
        }
        return nil
    }
}
