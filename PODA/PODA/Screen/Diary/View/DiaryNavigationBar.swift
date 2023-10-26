//
//  DiaryNavigationBar.swift
//  PODA
//
//  Created by 배은서 on 2023/10/20.
//

import UIKit
import SnapKit
import Then

class DiaryNavigationBar: UIView {
    
    // MARK: - Properties
    
    var leftButton = UIButton()
    var rightButton = UIButton()
    
    // MARK: - Life Cycle
    
    init(leftButtonTitle: String, rightButtonTitle: String) {
        super.init(frame: .zero)
        leftButton.setUpButton(title: leftButtonTitle, podaFont: .subhead3)
        rightButton.setUpButton(title: rightButtonTitle, podaFont: .subhead3)
        
        [leftButton, rightButton].forEach {
            $0.tintColor = Palette.podaWhite.getColor()
        }
        
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    private func configUI() {
        backgroundColor = Palette.podaBlack.getColor()
        setupLayout()
    }
    
    private func setupLayout() {
        [leftButton, rightButton].forEach {
            addSubview($0)
        }
        
        leftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        rightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
