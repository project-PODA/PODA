//
//  SelectRatioViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then

enum Ratio {
    case square
    case rectangle
}

class SelectRatioViewController: BaseViewController, UIConfigurable {

    // MARK: - Properties
    
    private var ratio: Ratio?
    
    private lazy var cancelButton = UIButton().then {
        $0.setUpButton(title: "취소", podaFont: .subhead2)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
    }
    
    private lazy var nextButton = UIButton().then {
        $0.setUpButton(title: "다음", podaFont: .subhead2)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
    }
    
    private let messageLabel = UILabel().then {
        $0.setUpLabel(title: "템플릿을 골라주세요", podaFont: .body1)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var squareButton = UIButton().then {
        $0.setTitle("1:1", for: .normal)
        $0.titleLabel?.font = UIFont.podaFont(.display1)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.addTarget(self, action: #selector(touchUpSquareButton), for: .touchUpInside)
    }
    
    private lazy var rectangleButton = UIButton().then {
        $0.setTitle("3:4", for: .normal)
        $0.titleLabel?.font = UIFont.podaFont(.display1)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.addTarget(self, action: #selector(touchUpRectangleButton), for: .touchUpInside)
    }
    
    private let ratioStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 20
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    // MARK: - InitUI
    
    func configUI() {
        navigationController?.navigationBar.isHidden = true
        
        [squareButton, rectangleButton].forEach {
            ratioStackView.addArrangedSubview($0)
        }
        
        [cancelButton, nextButton, messageLabel, ratioStackView].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(nextButton.snp.bottom).offset(244)
            $0.centerX.equalToSuperview()
        }
        
        ratioStackView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        squareButton.snp.makeConstraints {
            $0.width.height.equalTo(157)
        }
        
        rectangleButton.snp.makeConstraints {
            $0.width.equalTo(118)
            $0.height.equalTo(157)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        let viewController = CreateDiaryViewController(viewModel: CreateDiaryViewModel(), ratio: ratio ?? .square)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func touchUpSquareButton() {
        ratio = .square
        squareButton.setTitleColor(Palette.podaGray5.getColor(), for: .normal)
        squareButton.backgroundColor = Palette.podaWhite.getColor()
        rectangleButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        rectangleButton.backgroundColor = Palette.podaGray5.getColor()
    }
    
    @objc private func touchUpRectangleButton() {
        ratio = .rectangle
        squareButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        squareButton.backgroundColor = Palette.podaGray5.getColor()
        rectangleButton.setTitleColor(Palette.podaGray5.getColor(), for: .normal)
        rectangleButton.backgroundColor = Palette.podaWhite.getColor()
    }
    
    // MARK: - Custom Method
}