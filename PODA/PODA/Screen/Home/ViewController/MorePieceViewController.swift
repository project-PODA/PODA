//
//  MorePieceViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/19.
//

import UIKit
import Then
import SnapKit

class MorePieceViewController: BaseViewController, UIConfigurable {
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "image_background") // 저장된 이미지 불러오기
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    // 터치하면 화면 사라지도록
    private let translucentView = UIView().then {
        $0.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.8)
        let fingerImageView = UIImageView().then {
            $0.image = UIImage(named: "icon_finger")
            $0.contentMode = .scaleAspectFill
        }
        let infoLabel = UILabel().then {
            $0.setUpLabel(title: "추억 조각들을 마음대로 드래그해보세요 !", podaFont: .caption)
            $0.textColor = Palette.podaWhite.getColor()
        }
        [fingerImageView, infoLabel].forEach($0.addSubview)
        fingerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(248)
            make.width.height.equalTo(140)
        }
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(fingerImageView.snp.bottom).offset(20)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        hideTranslucentView()
    }
    
    func configUI() {
        [backgroundImageView, backButton, translucentView].forEach(view.addSubview)
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        
        translucentView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    func hideTranslucentView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTranslucentView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapTranslucentView() {
        translucentView.isHidden = true
    }
}

