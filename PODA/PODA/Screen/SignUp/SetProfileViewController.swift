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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setActions()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setActions() {
        cameraButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nicknameTextField {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let isWithinLimit = newText.count <= 5
            nicknameWarningLabel.isHidden = isWithinLimit
            return isWithinLimit
        }
        return true
    }    
    
    func configUI() {
        
        [titleLabel, profileImageView, cameraButton, nicknameTextField, nicknameUnderlineView, nicknameWarningLabel].forEach { view.addSubview($0) }
        
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
    }
    
    @objc private func openGallery() {
        let picker = UIImagePickerController().then {
            $0.delegate = self
            $0.sourceType = .photoLibrary
        }
        self.present(picker, animated: true, completion: nil)
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
