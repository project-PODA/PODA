//
//  SelectRatioViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then

class SelectRatioViewController: BaseViewController, UIConfigurable, ViewModelBindable {

    // MARK: - Properties
    
    var viewModel: CreateDiaryViewModel!
    
    private var alertController: UIAlertController {
        let alertController = UIAlertController(title: "알림", message: "템플릿을 골라주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alertController.addAction(okAction)
        
        return alertController
    }
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "취소", rightButtonTitle: "다음").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
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
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 30
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindViewModel()
    }
    
    init(viewModel: CreateDiaryViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    func configUI() {
        [squareButton, rectangleButton].forEach {
            ratioStackView.addArrangedSubview($0)
        }
        
        [messageLabel, ratioStackView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [navigationBar, stackView].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        squareButton.snp.makeConstraints {
            $0.width.height.equalTo(157)
        }
        
        rectangleButton.snp.makeConstraints {
            $0.width.equalTo(118)
            $0.height.equalTo(157)
        }
    }
    
    //MARK: - View Model Method
    
    func bindViewModel() {
        viewModel.ratio.addObserver { [weak self] ratio in
            guard let self = self else { return }
            
            switch ratio {
            case .square:
                squareButton.setTitleColor(Palette.podaGray5.getColor(), for: .normal)
                squareButton.backgroundColor = Palette.podaWhite.getColor()
                rectangleButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                rectangleButton.backgroundColor = Palette.podaGray5.getColor()
            case .rectangle:
                squareButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                squareButton.backgroundColor = Palette.podaGray5.getColor()
                rectangleButton.setTitleColor(Palette.podaGray5.getColor(), for: .normal)
                rectangleButton.backgroundColor = Palette.podaWhite.getColor()
            case .none: return
            }
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        if let ratio = viewModel.getRatio() {
            let viewController = CreateDiaryViewController(viewModel: viewModel, ratio: ratio)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            present(alertController, animated: true)
        }
    }
    
    @objc private func touchUpSquareButton() {
        viewModel.handleSquareButton()
    }
    
    @objc private func touchUpRectangleButton() {
        viewModel.handleRectangleButton()
    }
    
    // MARK: - Custom Method
}
