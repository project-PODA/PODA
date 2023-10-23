//
//  SetProfileViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/19.
//

import UIKit
import Then
import SnapKit

class SetProfileViewController: BaseViewController, UIConfigurable {
    
    var email: String = ""
    var password: String = ""
    private var firebaseAuth = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    
    
    private let titleLabel = UILabel().then {
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
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 105
        $0.clipsToBounds = true
        $0.image = UIImage(named: "image_profile")
    }
    
    private let cameraButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "icon_camera"), for: .normal)
        $0.layer.cornerRadius = 22
    }
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "ex. 김포다"
        $0.textColor = Palette.podaBlack.getColor()
        $0.attributedPlaceholder = NSAttributedString(string: "ex. 김포다", attributes: [NSAttributedString.Key.foregroundColor: Palette.podaGray3.getColor()])
    }
    
    private let nicknameUnderlineView = UIView().then {
        $0.backgroundColor = Palette.podaGray3.getColor()
    }
    
    private let nicknameWarningLabel = UILabel().then {
        $0.textColor = Palette.podaRed.getColor()
        $0.isHidden = true
        $0.setUpLabel(title: "5자 이내로 입력해주세요.", podaFont: .caption)
    }
    
    private let clearButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_delete"), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
    }
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textColor = Palette.podaGray3.getColor()
        $0.setUpLabel(title: "프로필 정보는 내가 친구간 커뮤니케이션\n동의목적으로 활용되며, PODA 이용기간동안 보관됩니다.", podaFont: .caption)
    }
    
    private let signUpButton = UIButton().then {
        $0.setUpButton(title: "가입 완료", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setActions()
        nicknameTextField.delegate = self
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setActions() {
        cameraButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(navigateToCompleteSignUp), for: .touchUpInside)

    }
    
    
    func configUI() {
        nicknameTextField.rightView = clearButton
        nicknameTextField.rightViewMode = .whileEditing
        
        [titleLabel, profileImageView, cameraButton, nicknameTextField, nicknameUnderlineView, nicknameWarningLabel, descriptionLabel, signUpButton].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
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
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameWarningLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    @objc private func openGallery() {
        let picker = UIImagePickerController().then {
            $0.delegate = self
            $0.sourceType = .photoLibrary
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc private func clearTextField() {
        nicknameTextField.text = ""
        nicknameWarningLabel.isHidden = true
    }
    
    @objc private func navigateToCompleteSignUp() {
        guard let _ = nicknameTextField.text, let imageData = profileImageView.image?.jpegData(compressionQuality: 0.5) else {
            showAlert(title: "에러", message: "데이터가 올바르지 않습니다. 확인해주세요.")
            return
        }
        if nicknameTextField.text == "" {
            showAlert(title: "에러", message: "닉네임을 입력해주세요.")
            return
        }
        
        firebaseAuth.signUpUser(email: email, password: password, profileImage: imageData, nickName: nicknameTextField.text!) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error == .none {
                    let completeSignUpVC = CompleteSignUpViewController()
                    self.navigationController?.pushViewController(completeSignUpVC, animated: true)
                } else {
                    self.showAlert(title: "에러", message: error.description)
                }
            }
        }
    }
}

extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SetProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nicknameTextField {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let isWithinLimit = newText.count <= 5
            nicknameWarningLabel.isHidden = isWithinLimit
            return isWithinLimit
        }
        return true
    }
}
