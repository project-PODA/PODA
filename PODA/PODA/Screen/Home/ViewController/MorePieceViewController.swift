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
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
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
        
        fingerImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(248)
            $0.width.height.equalTo(140)
        }
        infoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(fingerImageView.snp.bottom).offset(20)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        hideTranslucentView()
    }
    
    func configUI() {
        [backgroundImageView, backButton, translucentView].forEach {
            view.addSubview($0)
        }
        
        backgroundImageView.snp.makeConstraints { 
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        translucentView.snp.makeConstraints { 
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    func hideTranslucentView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTranslucentView))
        translucentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapTranslucentView() {
        translucentView.isHidden = true
    }
}

