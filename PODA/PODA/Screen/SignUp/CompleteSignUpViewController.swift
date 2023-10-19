//
//  CompleteSignUp.swift
//  PODA
//
//  Created by FUTURE on 2023/10/19.
//

import UIKit
import Then
import SnapKit

class CompleteSignUpViewController: BaseViewController, UIConfigurable {
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let font = UIFont.podaFont(.display1)
        let attributedString = NSAttributedString(string: "회원가입이 완료되었습니다.\n추억 보관을 시작해보세요 !", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: Palette.podaWhite.getColor()
        ])
        $0.attributedText = attributedString
    }
    
    private let checkImageView = UIImageView().then {
        $0.image = UIImage(named: "image_check")
        $0.contentMode = .scaleAspectFit
    }
    
    private let letsLoginButton = UIButton().then {
        $0.setUpButton(title: "로그인 하러가기", podaFont: .button1, cornerRadius: 22)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    func configUI() {
        [titleLabel, checkImageView].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(titleLabel)
            make.width.height.equalTo(148)
        }
        
        letsLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    
    
    
    
    
    
}
