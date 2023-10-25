//
//  SaveDeleteViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/22.
//

import UIKit

class SaveDeleteViewController: BaseViewController, UIConfigurable {
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.06", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "example") // 저장된 이미지 보여주기
    }
    
    private let saveButton = UIButton().then {
        $0.setUpButton(title: "save", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let deleteButton = UIButton().then {
        $0.setUpButton(title: "delete", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    func configUI() {
        let navigationBarStackView = UIStackView(arrangedSubviews: [backButton, dateLabel, addButton])
        navigationBarStackView.axis = .horizontal
        navigationBarStackView.alignment = .center
        navigationBarStackView.distribution = .equalSpacing
        
        let buttonStackView = UIStackView(arrangedSubviews: [saveButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillProportionally
        
        [navigationBarStackView, imageView, buttonStackView].forEach(view.addSubview)
        
        backButton.snp.makeConstraints { 
            $0.width.height.equalTo(30)
        }
        
        addButton.snp.makeConstraints { 
            $0.width.height.equalTo(30)
        }
        
        navigationBarStackView.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        imageView.snp.makeConstraints { 
            $0.top.equalTo(navigationBarStackView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            //$0.height.equalTo(512)
            $0.height.equalTo(view.frame.width * 1.25)
        }
        
        buttonStackView.snp.makeConstraints { 
            $0.top.equalTo(imageView.snp.bottom).offset(72)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapAddButton() {
        
    }
    
    @objc func didTapSaveButton() {
        // 저장되었습니다 토스트 메세지 띄우기 & 앨범에 이미지 추가
    }
    
    @objc func didTapDeleteButton() {
        // 삭제되었습니다 토스트 메세지 띄우기 & 삭제하고 데이터 저장
    }
    
}
