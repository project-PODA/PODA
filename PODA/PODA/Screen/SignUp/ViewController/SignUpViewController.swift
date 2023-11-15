//
//  SignUpViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/17.
//

import UIKit
import Then
import SnapKit
import NVActivityIndicatorView

class SignUpViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    private lazy var loadingIndicator = CustomLoadingIndicator()
    
    // MARK: BindViewModel
    
    var viewModel: SignUpViewModel!
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel() {
        viewModel.emailText.addObserver { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .success:
                    self.emailErrorLabel.isHidden = true
                    self.emailSendButton.backgroundColor = Palette.podaBlue.getColor()
                    self.verifyCodeButton.isEnabled = true
                case .wrongFormat:
                    self.emailErrorLabel.isHidden = false
                    self.emailSendButton.backgroundColor = Palette.podaGray4.getColor()
                    self.verifyCodeButton.backgroundColor = Palette.podaGray4.getColor()
                    self.verifyCodeButton.isEnabled = false
                case .none:
                    break
                }
            }
        }
        
        viewModel.passwordText.addObserver { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .success:
                    self.passwordErrorLabel.isHidden = true
                case .wrongFormat:
                    self.passwordErrorLabel.isHidden = false
                    self.passwordErrorLabel.text = "양식을 지켜 다시 입력해주세요."
                    self.passwordErrorLabel.textColor = Palette.podaRed.getColor()
                case .none:
                    self.passwordErrorLabel.isHidden = true
                    self.passwordErrorLabel.text = "비밀번호 확인을 위해 다시 한번 입력해주세요."
                    self.passwordErrorLabel.textColor = Palette.podaBlue.getColor()
                }
            }
        }
        
        viewModel.authText.addObserver { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .success:
                    self.updateUIForAuthSuccess()
                case .wrongFormat:
                    self.updateUIForAuthFailure()
                case .none:
                    break
                }
            }
        }
        
        viewModel.passwordRepeatText.addObserver { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .success:
                    self.passwordConfirmationErrorLabel.isHidden = false
                    self.passwordConfirmationErrorLabel.text = "비밀번호가 일치합니다."
                    self.passwordConfirmationErrorLabel.textColor = Palette.podaBlue.getColor()
                    self.updateSignUpButtonAppearance()
                case .wrongFormat:
                    self.passwordConfirmationErrorLabel.isHidden = false
                    self.passwordConfirmationErrorLabel.text = "비밀번호가 일치하지 않습니다."
                    self.passwordConfirmationErrorLabel.textColor = Palette.podaRed.getColor()
                case .none:
                    break
                }
            }
        }
        
        viewModel.isSignUpAllowed.addObserver { [weak self] isAllowed in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.signUpButton.isEnabled = isAllowed
            }
        }
        
        viewModel.completeSignup.addObserver { [weak self] signUpStatus in
            guard let self = self else { return }
            loadingIndicator.stopAnimating()
            switch signUpStatus {
            case .success:
                let completeSignUpVC = CompleteSignUpViewController()
                navigationController?.pushViewController(completeSignUpVC, animated: true)
            case .error(let error):
                showAlert(title: "에러", message: error.description)
            default:
                break
            }
            
        }
    }
    
    // MARK: UIComponent
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back_podaBlue"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
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
        $0.placeholder = "ex. poda123@gmail.com"
        $0.borderStyle = .none
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
        $0.keyboardType = .emailAddress
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
        $0.placeholder = "인증코드 입력"
        $0.borderStyle = .none
        $0.backgroundColor = Palette.podaGray1.getColor()
        $0.layer.cornerRadius = 5
    }
    private let verificationCodeErrorLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = true
        $0.setUpLabel(title: "인증코드가 올바르지 않습니다. 다시 확인해주세요.", podaFont: .caption)
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
        $0.setUpLabel(title: "영문, 숫자, 특수문자 3가지를 포함하여 6-15자로 입력해주세요", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호 입력"
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
        $0.placeholder = "비밀번호 다시 입력"
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
    
    
    private let passwordConfirmationErrorLabel = UILabel().then {
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
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActions()
        configUI()
        setupTextFields()
        hideKeyboardWhenTappedAround()
        emailTextField.enableHideKeyboardOnReturn()
        passwordTextField.enableHideKeyboardOnReturn()
        passwordConfirmationTextField.enableHideKeyboardOnReturn()
        verificationCodeTextField.enableHideKeyboardOnReturn()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: ConfigUI, Constraints
    
    func configUI() {
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [emailLabel, emailTextField, emailDeleteButton, emailErrorLabel, emailSendButton, verificationCodeLabel, verificationCodeDetailLabel, verificationCodeTextField, verificationCodeDeleteButton, verifyCodeButton, verificationCodeErrorLabel, passwordLabel, passwordTextField, passwordDetailLabel, passwordEyeButton, passwordErrorLabel, passwordConfirmationLabel, passwordConfirmationTextField, confirmPasswordEyeButton, passwordConfirmationErrorLabel,loadingIndicator].forEach { contentView.addSubview($0) }
        view.addSubview(signUpButton)
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(30)
            $0.leading.equalTo(view.snp.leading).offset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view)
            $0.bottom.equalTo(passwordConfirmationErrorLabel.snp.bottom)
        }
        
        contentView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        emailLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(contentView.snp.top).offset(30)
        }
        
        emailTextField.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.right.equalTo(emailSendButton.snp.left).offset(-5)
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }
        
        emailDeleteButton.snp.makeConstraints {
            $0.right.equalTo(emailSendButton.snp.left).offset(-5)
            $0.centerY.equalTo(emailTextField)
            $0.width.height.equalTo(36)
        }
        
        emailErrorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(4)
            $0.left.equalTo(emailLabel)
        }
        
        emailSendButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(emailTextField)
            $0.width.equalTo(80)
            $0.height.equalTo(emailTextField)
        }
        
        verificationCodeLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(emailTextField.snp.bottom).offset(50)
        }
        
        verificationCodeDetailLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(verificationCodeLabel.snp.bottom).offset(4)
        }
        
        verificationCodeTextField.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.right.equalTo(verifyCodeButton.snp.left).offset(-4)
            $0.top.equalTo(verificationCodeDetailLabel.snp.bottom).offset(10)
            $0.height.equalTo(emailTextField)
        }
        
        verificationCodeDeleteButton.snp.makeConstraints {
            $0.right.equalTo(verifyCodeButton.snp.left).offset(-5)
            $0.centerY.equalTo(verificationCodeTextField)
            $0.width.height.equalTo(36)
        }
        
        verifyCodeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(verificationCodeTextField)
            $0.width.equalTo(80)
            $0.height.equalTo(emailTextField)
        }
        
        verificationCodeErrorLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(verificationCodeTextField.snp.bottom).offset(4)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(verificationCodeTextField.snp.bottom).offset(50)
        }
        
        passwordDetailLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(passwordLabel.snp.bottom).offset(4)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.right.equalTo(passwordEyeButton.snp.left).offset(-10)
            $0.top.equalTo(passwordDetailLabel.snp.bottom).offset(10)
            $0.height.equalTo(emailTextField)
        }
        
        passwordEyeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(passwordTextField)
            $0.width.height.equalTo(24)
        }
        
        passwordErrorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.left.equalTo(emailLabel)
        }
        
        passwordConfirmationLabel.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(50)
        }
        
        passwordConfirmationTextField.snp.makeConstraints {
            $0.left.equalTo(emailLabel)
            $0.right.equalTo(confirmPasswordEyeButton.snp.left).offset(-10)
            $0.top.equalTo(passwordConfirmationLabel.snp.bottom).offset(10)
            $0.height.equalTo(emailTextField)
        }
        
        confirmPasswordEyeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(passwordConfirmationTextField)
            $0.width.height.equalTo(24)
        }
        
        passwordConfirmationErrorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmationTextField.snp.bottom).offset(4)
            $0.left.equalTo(emailLabel)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        
        signUpButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.top.equalTo(scrollView.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: AddTarget
    
    private func setActions() {
        passwordEyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        confirmPasswordEyeButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility(_:)), for: .touchUpInside)
        emailDeleteButton.addTarget(self, action: #selector(clearEmailField(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        verificationCodeDeleteButton.addTarget(self, action: #selector(clearVerificationCodeField(_:)), for: .touchUpInside)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        passwordConfirmationTextField.addTarget(self, action: #selector(passwordConfirmationTextFieldDidChange(_:)), for: .editingChanged)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        //인증코드 및 확인 버튼 추가
        emailSendButton.addTarget(self, action: #selector(sendAuthUserCode), for: .touchUpInside)
        verifyCodeButton.addTarget(self, action: #selector(checkAuthUserCode), for: .touchUpInside)
        
    }
    
    // MARK: Function
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateUIForAuthSuccess() {
        verificationCodeErrorLabel.isHidden = false
        verificationCodeErrorLabel.textColor = Palette.podaBlue.getColor()
        verificationCodeErrorLabel.text = "인증이 완료되었습니다."
        
        verifyCodeButton.isEnabled = false
        verifyCodeButton.backgroundColor = Palette.podaGray4.getColor()
        verifyCodeButton.setTitle("인증완료", for: .normal)
        
        emailTextField.backgroundColor = Palette.podaGray2.getColor()
        emailTextField.isEnabled = false
        
        emailSendButton.backgroundColor = Palette.podaGray4.getColor()
        emailSendButton.isEnabled = false
        
        verificationCodeTextField.isEnabled = false
        verificationCodeTextField.backgroundColor = Palette.podaGray2.getColor()
        
        emailDeleteButton.isHidden = true
        verificationCodeDeleteButton.isHidden = true
    }
    
    private func updateUIForAuthFailure() {
        verificationCodeErrorLabel.isHidden = false
        verificationCodeErrorLabel.textColor = Palette.podaRed.getColor()
        verificationCodeErrorLabel.text = "인증에 실패했습니다. 다시 확인해주세요."
    }
    
    private func setComponentDisable(_ enabled : Bool){
        emailTextField.isEnabled = enabled
        emailDeleteButton.isEnabled = enabled
        emailSendButton.isEnabled = enabled
        
        passwordTextField.isEnabled = enabled
        passwordEyeButton.isEnabled = enabled
        passwordConfirmationTextField.isEnabled = enabled
        
        verificationCodeTextField.isEnabled = enabled
        verificationCodeDeleteButton.isEnabled = enabled
        verifyCodeButton.isEnabled = enabled
        
        confirmPasswordEyeButton.isEnabled = enabled
        
        signUpButton.isEnabled = enabled
    }
    
    func updateSignUpButtonAppearance() {
        if viewModel.authCodeSuccess && viewModel.emailAuthSuccess && viewModel.passwordAuthSuccess {
            signUpButton.backgroundColor = Palette.podaBlue.getColor()
            signUpButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        } else {
            signUpButton.setUpButton(title: "가입하기", podaFont: .button1, cornerRadius: 22)
            signUpButton.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
            signUpButton.layer.borderColor = Palette.podaBlue.getColor().cgColor
            signUpButton.layer.borderWidth = 1
        }
    }
    
    // MARK: Objc Functions
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearEmailField(_ sender: UIButton) {
        emailTextField.text = ""
    }
    
    @objc private func clearVerificationCodeField(_ sender: UIButton) {
        verificationCodeTextField.text = ""
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        viewModel.setEmailText(email: email)
    }
    
    @objc private func passwordTextFieldDidChange(_ textField: UITextField) {
        guard let password = textField.text else { return }
        viewModel.setPasswordText(password: password)
        // 비밀번호 텍스트 필드 내용 변경되면 비밀번호 확인 텍스트 필드를 비우기
        passwordConfirmationTextField.text = ""
        passwordConfirmationErrorLabel.text = "비밀번호가 일치하지 않습니다."
        passwordConfirmationErrorLabel.textColor = Palette.podaRed.getColor()
    }
    
    @objc private func passwordConfirmationTextFieldDidChange(_ textField: UITextField) {
        guard let confirmPassword = textField.text else { return }
        viewModel.setPasswordConfirmationText(confirmPassword)
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
    
    //    @objc private func signUpButtonTapped() {
    //        guard viewModel.isSignUpAllowed.value else { return }
    //
    //        let agreeTermsVC = AgreeTermsViewController()
    //        let setProfileVC = SetProfileViewController(viewModel: SetProfileViewModel(firebaseAuth: FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))), email: emailTextField.text!.lowercased(), password: passwordTextField.text!)
    //        setProfileVC.bind(to: setProfileVC.viewModel)
    //
    //        agreeTermsVC.setProfileVC = setProfileVC
    //
    //        self.navigationController?.pushViewController(agreeTermsVC, animated: true)
    //    }
    
    @objc private func signUpButtonTapped() {
        guard viewModel.isSignUpAllowed.value else { return }
        loadingIndicator.startAnimating()
        viewModel.onCompleteSingupTapped()
        
        //        let completeVC = CompleteSignUpViewController()
        
        //        self.navigationController?.pushViewController(completeVC, animated: true)
    }
    
    @objc private func sendAuthUserCode() {
        guard let email = emailTextField.text?.lowercased(), !email.isEmpty else {
            showAlert(title: "에러", message: "이메일 주소를 입력해주세요.")
            return
        }
        
        loadingIndicator.startAnimating()
        setComponentDisable(false)
        
        viewModel.sendAuthCode(email: email) { [weak self] (success, message) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.setComponentDisable(true)
                
                if success {
                    self.emailErrorLabel.isHidden = false
                    self.emailErrorLabel.textColor = Palette.podaBlue.getColor()
                    self.emailErrorLabel.text = message
                    self.verificationCodeErrorLabel.isHidden = false
                    self.verificationCodeErrorLabel.textColor = Palette.podaRed.getColor()
                    self.verificationCodeErrorLabel.text = "입력 완료 후 인증하기 버튼을 눌러주세요."
                    self.emailSendButton.backgroundColor = Palette.podaGray4.getColor()
                    self.verifyCodeButton.backgroundColor = Palette.podaBlue.getColor()
                } else {
                    self.showAlert(title: "에러", message: message ?? "인증에 실패했습니다.")
                    self.emailSendButton.isEnabled = true
                    self.verifyCodeButton.isEnabled = true
                }
            }
        }
    }
    
    @objc private func checkAuthUserCode() {
        guard let authCode = verificationCodeTextField.text else { return }
        
        viewModel.checkAuthCode(inputCode: authCode)
    }
    
    //💥deinit 추가!! dismiss추가
}

// MARK: Extensions

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

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTextField {
            // 비밀번호 텍스트 필드의 텍스트가 변경되면 비밀번호 확인 필드를 비우기
            passwordConfirmationTextField.text = ""
        }
        return true
    }
    
    func setupTextFields() {
        emailTextField.setUpTextField(delegate: self)
        verificationCodeTextField.setUpTextField(delegate: self)
        passwordTextField.setUpTextField(delegate: self)
        passwordConfirmationTextField.setUpTextField(delegate: self)
    }
}
