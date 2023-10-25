//
//  DetailDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then

class DetailDiaryViewController: BaseViewController, UIConfigurable {

    // MARK: - Properties
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "뒤로", rightButtonTitle: "저장").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpSaveButton), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.setUpLabel(title: "다이어리 제목", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let titleTextField = UITextField().then {
        $0.font = UIFont.podaFont(.body1)
        $0.textColor = Palette.podaGray4.getColor()
        $0.placeholder = "ex. 포다랑 인생네컷 모음"
        $0.borderStyle = .none
    }
    
    private let underLine = UIView().then {
        $0.backgroundColor = Palette.podaGray3.getColor()
    }
    
    private let titleCountLabel = UILabel().then {
        $0.setUpLabel(title: "0자 / 14자", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let contentLabel = UILabel().then {
        $0.setUpLabel(title: "내용", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let contentTextView = UITextView().then {
        $0.font = UIFont.podaFont(.body1)
        $0.text = "내용을 입력하세요."
        $0.textColor = Palette.podaGray4.getColor()
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 5
        $0.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    private let contentCountLabel = UILabel().then {
        $0.setUpLabel(title: "0자 / 100자", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        hideKeyboardWhenTappedAround()
        titleTextField.enableHideKeyboardOnReturn()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - InitUI
    
    func configUI() {
        setupLayout()
    }
    
    private func setupLayout() {
        [navigationBar,
         titleLabel, titleTextField, underLine, titleCountLabel,
         contentLabel, contentTextView, contentCountLabel
        ].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(35)
            $0.leading.equalToSuperview().inset(20)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(20)
        }
        
        underLine.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        titleCountLabel.snp.makeConstraints {
            $0.top.equalTo(underLine.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleCountLabel.snp.bottom).offset(57)
            $0.leading.equalToSuperview().inset(22)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(353)
            $0.height.equalTo(166)
        }
        
        contentCountLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpSaveButton() {
        
    }
    
    // MARK: - Custom Method

}
