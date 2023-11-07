//
//  DetailDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then
import NVActivityIndicatorView

class DetailDiaryViewController: BaseViewController, UIConfigurable, ViewModelBindable {
    
    // MARK: - Properties
    
    static let createDiaryNotificationName = NSNotification.Name("createDiary")
    
    var viewModel: CreateDiaryViewModel!
    
    private lazy var loadingIndicator = CustomLoadingIndicator()
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "뒤로", rightButtonTitle: "저장").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpSaveButton), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.setUpLabel(title: "다이어리 제목", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var titleTextField = UITextField().then {
        $0.font = UIFont.podaFont(.body2)
        $0.textColor = Palette.podaGray2.getColor()
        $0.placeholder = "ex. 포다랑 인생네컷 모음"
        $0.borderStyle = .none
        $0.enableHideKeyboardOnReturn()
        $0.addTarget(self, action: #selector(titleTextDidChange(_:)), for: .editingChanged)
    }
    
    private let underLine = UIView().then {
        $0.backgroundColor = Palette.podaGray3.getColor()
    }
    
    private let titleCountLabel = UILabel().then {
        $0.setUpLabel(title: "0자 / 12자", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let contentLabel = UILabel().then {
        $0.setUpLabel(title: "내용", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var contentTextView = UITextView().then {
        $0.font = UIFont.podaFont(.body1)
        $0.text = "내용을 입력하세요."
        $0.textColor = Palette.podaGray4.getColor()
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 5
        $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.delegate = self
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
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(loadingIndicator)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    init(viewModel: CreateDiaryViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    func configUI() {
        setupLayout()
    }
    
    private func setupLayout() {
        [loadingIndicator, navigationBar,
         titleLabel, titleTextField, underLine, titleCountLabel,
         contentLabel, contentTextView, contentCountLabel
        ].forEach {
            view.addSubview($0)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
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
            $0.leading.trailing.equalToSuperview().inset(20)
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
        if viewModel.isFilledAll(title: titleTextField.text, content: contentTextView.text) {
            showAlert()
        } else {
            loadingIndicator.startAnimating()
            
            viewModel.handleSaveButton { [weak self] in
                guard let self = self, let viewControllers = navigationController?.viewControllers else { return }
                for viewController in viewControllers {
                    if viewController is BaseTabbarController {
                        NotificationCenter.default.post(
                            name: DetailDiaryViewController.createDiaryNotificationName,
                            object: viewModel.getDiaryData()
                        )
                        self.loadingIndicator.stopAnimating()
                        
                        self.navigationController?.popToViewController(viewController, animated: true)
                        break
                    }
                }
            }
        }
    }
        
    @objc func titleTextDidChange(_ textField: UITextField) {
        // title TextField 값이 변하면 메소드 호출 -> 이 메소드에 viewModel의 titleCount 값이 변하도록 구현함
        // titleCount 값이 변하면 아래 🚀이 실행됨
        viewModel.setTitle(textField.text ?? "")
        viewModel.handleTitleTextField(textCount: textField.text?.count ?? 0)
    }
    
    // MARK: - Custom Method
    
    func bindViewModel() {
        // 🚀
        viewModel.titleTextCount.addObserver { [weak self] textCount in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.titleCountLabel.text = "\(textCount)자 / 12자"
                
                if textCount > 12 {
                    self.titleTextField.text = String(self.titleTextField.text!.prefix(12))
                }
            }
        }
        
        viewModel.contentTextCount.addObserver { [weak self] textCount in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.contentCountLabel.text = "\(textCount)자 / 100자"
                
                if textCount > 12 {
                    self.contentTextView.text = String(self.contentTextView.text.prefix(100))
                }
            }
        }
        
        viewModel.content.addObserver { [weak self] content in
            guard let self = self else { return }
            if content == "내용을 입력하세요." {
                contentTextView.text = ""
                contentTextView.textColor = Palette.podaGray2.getColor()
            }
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "알림", message: "제목과 내용을 모두 적어주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension DetailDiaryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.setContent(textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.setContent(textView.text)
        viewModel.handleContentTextView(textCount: textView.text.count)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "내용을 입력하세요."
            textView.textColor = Palette.podaGray4.getColor()
        }
    }
}
