//
//  SetProfileViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/19.
//

import UIKit
import Then
import SnapKit
import NVActivityIndicatorView
import PhotosUI

class SetProfileViewController: BaseViewController, UIConfigurable, ViewModelBindable {
    
    var viewModel: SetProfileViewModel!

    init(viewModel: SetProfileViewModel, email: String, password: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.updateData(email: email, password: password)
        self.viewModel.setProfileImage(imageData: profileImageView.image?.pngData())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back_podaBlue"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let font = UIFont.podaFont(.display1)
        let attributedString = NSAttributedString(string: "사진과 닉네임을\n등록해주세요", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font
        ])
        $0.attributedText = attributedString
    }
    
    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 105
        $0.clipsToBounds = true
        $0.image = UIImage(named: "image_profile")
    }
    
    private lazy var cameraButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "icon_camera"), for: .normal)
        $0.layer.cornerRadius = 22
    }
    
    private lazy var nicknameTextField = UITextField().then {
        $0.placeholder = "ex. 김포다"
        $0.textColor = Palette.podaBlack.getColor()
        $0.attributedPlaceholder = NSAttributedString(string: "ex. 김포다", attributes: [NSAttributedString.Key.foregroundColor: Palette.podaGray3.getColor()])
        $0.delegate = self
        $0.rightView = clearButton
        $0.rightViewMode = .whileEditing
    }
    
    private lazy var nicknameUnderlineView = UIView().then {
        $0.backgroundColor = Palette.podaGray3.getColor()
    }
    
    private lazy var nicknameWarningLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = false
        $0.setUpLabel(title: "5자 이내로 입력해주세요.", podaFont: .caption)
    }
    
    private lazy var clearButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_delete"), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
    }
        
    private lazy var signUpButton = UIButton().then {
        $0.setUpButton(title: "가입 완료", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    private lazy var loadingIndicator = CustomLoadingIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setActions()
        hideKeyboardWhenTappedAround()
        nicknameTextField.enableHideKeyboardOnReturn()
        nicknameTextField.delegate = self
    }
    
    func bindViewModel() {
        viewModel.profileImage.addObserver { [weak self] imageData in
            guard let self = self else { return }
            if let imageData = imageData {
                DispatchQueue.main.async { [weak self] in
                    self?.profileImageView.image = UIImage(data: imageData)
                }
            } else {
                showAlert(title: "에러", message: "이미지 정보를 찾을 수 없습니다.")
            }
        }
        
        viewModel.nicknameText.addObserver{ [weak self] nickNameText in
            guard let self = self else { return }
            if nickNameText.isEmpty {
                nicknameTextField.text = ""
                nicknameWarningLabel.isHidden = false
            } else if nickNameText.count > 5 {
                nicknameWarningLabel.isHidden = false
                makeAnimation(animationType: .shake, for: nicknameTextField)
            } else {
                nicknameWarningLabel.isHidden = true
            }
            updateSignUpButtonAppearance()
        }
        
        viewModel.completeSignup.addObserver { [weak self] signUpStatus in
            guard let self = self else { return }
            switch signUpStatus {
            case .success:
                let completeSignUpVC = CompleteSignUpViewController()
                navigationController?.pushViewController(completeSignUpVC, animated: true)
            case .emptyText:
                showAlert(title: "에러", message: "닉네임을 설정해 주세요.")
            case .exceedTextLength:
                showAlert(title: "에러", message: "5자 이내로 입력해주세요.")
                nicknameTextField.text = ""
            case .profileImageEmpty:
                showAlert(title: "에러", message: "이미지를 설정해 주세요.")
            case .error(let error):
                showAlert(title: "에러", message: error.description)
            default:
                break
            }
            setComponentEnable(true)
            loadingIndicator.stopAnimating()
        }
    }
    
    
    func setActions() {
        cameraButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(navigateToCompleteSignUp), for: .touchUpInside)
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: .editingChanged)
    }
    
    func configUI() {
        
        [backButton, titleLabel, profileImageView, cameraButton, nicknameTextField, nicknameUnderlineView, nicknameWarningLabel, signUpButton,loadingIndicator].forEach { view.addSubview($0) }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(50)
            make.width.height.equalTo(210)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(profileImageView).offset(-8)
            make.width.height.equalTo(44)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        nicknameUnderlineView.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(5)
            make.left.right.equalTo(nicknameTextField)
            make.height.equalTo(1)
        }
        
        nicknameWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameUnderlineView.snp.bottom).offset(5)
            make.left.right.equalTo(nicknameTextField)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func updateSignUpButtonAppearance() {
        if let nickname = nicknameTextField.text, !nickname.isEmpty {
            // 프로필 이름이 설정 완료
            signUpButton.backgroundColor = Palette.podaBlue.getColor()
            signUpButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
            signUpButton.layer.borderWidth = 0
        } else {
            // 프로필 이름 비어있을 때
            signUpButton.setUpButton(title: "가입 완료", podaFont: .button1, cornerRadius: 22)
            signUpButton.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
            signUpButton.backgroundColor = Palette.podaWhite.getColor()
            signUpButton.layer.borderColor = Palette.podaBlue.getColor().cgColor
            signUpButton.layer.borderWidth = 1
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func openGallery() {
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { [weak self] isAuthorized in
            DispatchQueue.main.async {
                if isAuthorized {
                    var configuration = PHPickerConfiguration()
                    configuration.filter = .images
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    self?.present(picker, animated: true, completion: nil)
                }
            }
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSignUpButtonAppearance()
    }
    
    @objc private func clearTextField() {
        viewModel.setNickName(nickname: "")
    }
    private func setComponentEnable(_ enabled : Bool){
        cameraButton.isEnabled = enabled
        clearButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        nicknameTextField.isEnabled = enabled
    }
    
    @objc private func navigateToCompleteSignUp() {
        loadingIndicator.startAnimating()
        setComponentEnable(false)
        viewModel.onCompleteSingupTapped()
    }
}

extension SetProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nicknameTextField {
            if let newText = textField.text {
                viewModel.setNickName(nickname: newText)
            }
        }
    }
}

extension SetProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else {
            return
        }
        
        let selectedResult = results[0]
        
        selectedResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            guard let self = self else { return }
            if let error = error {
                showAlert(title: "에러", message: error.localizedDescription)
            } else if let selectedImage = object as? UIImage {
                viewModel.setProfileImage(imageData: selectedImage.pngData())
            }
        }
    }
}
