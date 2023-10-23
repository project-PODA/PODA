//
//  SaveDeleteViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/22.
//

import UIKit

class SaveDeleteViewController: BaseViewController, UIConfigurable {
    
    private let backButton = UIButton().then {
        //$0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.06", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let addButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
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
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        navigationBarStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarStackView.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(512)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-116)
        }
    }
    
    @objc func didTapBackButton() {
        //dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapAddButton() {
        
    }
    
    @objc func didTapEditButton() {
        // 추억 다이어리 만들기 페이지로 이동
    }
    
    @objc func didTapSaveButton() {
        // 저장되었습니다 토스메세지 띄우기 & 앨범에 이미지 추가
    }
    
    @objc func didTapDeleteButton() {
        // 삭제되었습니다 토스메세지 띄우기 & 삭제하고 데이터 저장
    }
    
}
