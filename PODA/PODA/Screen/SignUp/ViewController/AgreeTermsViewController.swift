//
//  AgreeTermsViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/30.
//

import UIKit
import Then
import SnapKit

class AgreeTermsViewController: BaseViewController, UIConfigurable {
//    var setProfileVC: SetProfileViewController?
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back_podaBlue"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let font = UIFont.podaFont(.display1)
        let attributedString = NSAttributedString(string: "약관 동의를\n진행해주세요", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font
        ])
        $0.attributedText = attributedString
    }
    
    private let allAgreeLabel = UILabel().then {
        $0.setUpLabel(title: "전체 동의", podaFont: .subhead4)
    }
    
    private let termsOfUseLabel = UILabel().then {
        let attributedString = NSMutableAttributedString(string: "[필수] 이용 약관")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
        
    }
    
    private let privacyPolicyLabel = UILabel().then {
        let attributedString = NSMutableAttributedString(string: "[필수] 개인정보 처리 방침")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
    }
    
    
    private let allAgreeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
    }
    
    private let termsOfUseButton = UIButton().then {
        $0.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
    }
    
    private let privacyPolicyButton = UIButton().then {
        $0.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
    }
    
    private let nextButton = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.setUpButton(title: "다음", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupActions()
        setupGestureRecognizers()
        
    }
    
    func configUI() {
        [backButton, titleLabel, nextButton, allAgreeLabel, termsOfUseLabel, privacyPolicyLabel, allAgreeButton, termsOfUseButton, privacyPolicyButton].forEach { view.addSubview($0) }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(30)
            $0.leading.equalTo(view.snp.leading).offset(20)
        }
        
        
        allAgreeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(80)
            $0.leading.equalTo(titleLabel)
        }
        
        allAgreeButton.snp.makeConstraints {
            $0.centerY.equalTo(allAgreeLabel)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        
        termsOfUseLabel.snp.makeConstraints {
            $0.top.equalTo(allAgreeLabel.snp.bottom).offset(16)
            $0.leading.equalTo(titleLabel)
            
        }
        
        termsOfUseButton.snp.makeConstraints {
            $0.centerY.equalTo(termsOfUseLabel)
            $0.trailing.equalTo(allAgreeButton)
        }
        
        privacyPolicyLabel.snp.makeConstraints {
            $0.top.equalTo(termsOfUseLabel.snp.bottom).offset(16)
            $0.leading.equalTo(titleLabel)
        }
        
        privacyPolicyButton.snp.makeConstraints {
            $0.centerY.equalTo(privacyPolicyLabel)
            $0.trailing.equalTo(allAgreeButton)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func setupActions() {
        allAgreeButton.addTarget(self, action: #selector(didTapAllAgreeButton), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(didTapIndividualAgreeButton), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(didTapIndividualAgreeButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    func setupGestureRecognizers() {
        let termsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTermsOfUseLabel))
        termsOfUseLabel.addGestureRecognizer(termsTapGesture)
        termsOfUseLabel.isUserInteractionEnabled = true
        
        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPrivacyPolicyLabel))
        privacyPolicyLabel.addGestureRecognizer(privacyTapGesture)
        privacyPolicyLabel.isUserInteractionEnabled = true
    }
    
    @objc func didTapAllAgreeButton() {
        if allAgreeButton.currentImage == UIImage(systemName: "checkmark.circle") {
            allAgreeButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            termsOfUseButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            privacyPolicyButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            allAgreeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            termsOfUseButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            privacyPolicyButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        
        updateNextButtonState()
    }
    
    @objc func didTapIndividualAgreeButton(sender: UIButton) {
        if sender.currentImage == UIImage(systemName: "checkmark.circle") {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        
        let allFilled = [termsOfUseButton, privacyPolicyButton].allSatisfy {
            $0.currentImage == UIImage(systemName: "checkmark.circle.fill")
        }
        
        allAgreeButton.setImage(allFilled ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal)
        
        updateNextButtonState()
    }
    
    
    @objc func didTapTermsOfUseLabel() {
        if let url = URL(string: "https://poda-project.notion.site/f6e3b59ad589488c8079f184d11136a4?pvs=4") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @objc func didTapPrivacyPolicyLabel() {
        if let url = URL(string: "https://poda-project.notion.site/7f58cdb40f3348b8b486960f255b051e?pvs=4") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func didTapButton(_ button: UIButton) {
        if button.currentImage == UIImage(systemName: "checkmark.circle") {
            button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        
        let allFilled = [termsOfUseButton, privacyPolicyButton].allSatisfy {
            $0.currentImage == UIImage(systemName: "checkmark.circle.fill")
        }
        allAgreeButton.setImage(allFilled ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal)
    }
    
//    @objc func didTapNextButton() {
//        if let setProfileVC = self.setProfileVC {
//            self.navigationController?.pushViewController(setProfileVC, animated: true)
//        }
//    }
    
    @objc func didTapNextButton() {
        let viewModel = SignUpViewModel(
            firebaseAuthManager: FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator())),
            fireStorageManager: FirestorageDBManager(),
            smtpManager: SMTPManager(htmpParser: HTMLParser())
        )
        
        let signUpVC = SignUpViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func updateNextButtonState() {
        let allFilled = [allAgreeButton, termsOfUseButton, privacyPolicyButton].allSatisfy {
            $0.currentImage == UIImage(systemName: "checkmark.circle.fill")
        }
        
        if allFilled {
            nextButton.backgroundColor = Palette.podaBlue.getColor()
            nextButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
            nextButton.layer.borderColor = Palette.podaBlue.getColor().cgColor
            nextButton.isUserInteractionEnabled = true
        } else {
            nextButton.backgroundColor = Palette.podaWhite.getColor()
            nextButton.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
            nextButton.layer.borderColor = Palette.podaBlue.getColor().cgColor
            nextButton.isUserInteractionEnabled = false
        }
    }

}
