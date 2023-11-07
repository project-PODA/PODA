//
//  LeaveViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/24.
//

import UIKit
import SnapKit
import MessageUI
import Then

class LeaveViewController: BaseViewController, UIConfigurable {
    
    let viewModel: LeaveViewModel
    
    init(viewModel: LeaveViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let topLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.setUpLabel(title: "잠깐, 탈퇴하기 전에\n아래의 내용을 꼭 확인해주세요.", podaFont: .subhead4)
        $0.textColor = Palette.podaWhite.getColor()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        $0.attributedText = NSAttributedString(string: $0.text!, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private let middleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.setUpLabel(title: "• 모든 사진 데이터가 삭제됩니다.\n  (추억 조각, 다이어리 등)\n• 계정이 삭제된 후에는 복구하실 수 없습니다.\n• 계정 삭제 후에는 현재 계정으로 로그인 불가능합니다.", podaFont: .body2)
        $0.textColor = Palette.podaWhite.getColor()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        $0.attributedText = NSAttributedString(string: $0.text!, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private let bottomLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.setUpLabel(title: "아래의 탈퇴하기 버튼을 누르면\n현재 계정의 데이터가 영구적으로 삭제됩니다.", podaFont: .subhead2)
        $0.textColor = Palette.podaWhite.getColor()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        $0.attributedText = NSAttributedString(string: $0.text!, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private lazy var signOutButton = UIButton().then {
        $0.setUpButton(title: "탈퇴하기", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaRed.getColor()
        $0.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
    }
    
    private lazy var loadingIndicator = CustomLoadingIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let baseTabbar = self.tabBarController as? BaseTabbarController {
            baseTabbar.setCustomTabbarHidden(true)
        }
    }
    
    func configUI() {
        self.navigationItem.title = "탈퇴하기"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor(named: "podaWhite") ?? .white
        ]
        
        [topLabel, middleLabel, bottomLabel, signOutButton, loadingIndicator].forEach { view.addSubview($0) }
        
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        middleLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(topLabel)
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(middleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(topLabel)
        }
        
        signOutButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
           viewModel.onAccountDeletionSuccess = { [weak self] in
               DispatchQueue.main.async {
                   self?.loadingIndicator.stopAnimating()
                   self?.showAlert(title: "알림", message: "계정 삭제가 완료되었습니다.") {
                       self?.moveToHome()
                   }
               }
           }
           
           viewModel.onAccountDeletionFailure = { [weak self] message in
               DispatchQueue.main.async {
                   self?.loadingIndicator.stopAnimating()
                   self?.showAlert(title: "에러", message: message)
               }
           }
       }
    
    @objc func signOutButtonTapped() {
            showAlertWithTextField(title: "경고", message: "탈퇴를 원하시면 \"동의합니다\"를 입력해주세요", placeholder: "동의합니다") { [weak self] text in
                self?.loadingIndicator.startAnimating()
                self?.viewModel.deleteAccount(withConfirmation: text ?? "")
            }
        }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
