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
    
    var ratio: Ratio!
    var pageInfo: [PageInfo]!
    var diaryName : String?
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
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
        $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        titleTextField.addTarget(self, action: #selector(titleTextDidChange(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(contentTextDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        contentTextView.delegate = self
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
        if let title = titleTextField.text, title.isEmpty || contentTextView.text == "내용을 입력하세요." {
            showAlert()
        } else {
            var pageData = pageInfo!
            pageData[0].imageData = Data()
            
            firebaseDBManager.createDiary(
                deviceName: UIDevice.current.name,
                pageDataList: pageData, title: titleTextField.text!,
                description: contentTextView.text,
                frameRate: ratio) { [weak self] error in
                    
                guard let self = self else { return }

                if error == .none {
                    print("다이어리 성공")
                    firebaseImageManager.createDiaryImage(diaryName: titleTextField.text!, pageImage: pageInfo[0].imageData) { error in
                        if error == .none, let viewControllers = self.navigationController?.viewControllers {
                            print("다이어리 이미지 생성 성공")
                            for viewController in viewControllers {
                                if viewController is BaseTabbarController {
                                    self.navigationController?.popToViewController(viewController, animated: true)
                                    break
                                }
                            }
                        } else {
                            print("다이어리 이미지 생성 실패")
                        }
                    }
                } else {
                    print("다이어리 성공 실패")
                }
            }
        }
    }
    
    @objc func titleTextDidChange(_ textField: UITextField) {
        let textCount = textField.text?.count ?? 0
        titleCountLabel.text = "\(textCount)자 / 14자"
        if textCount > 14 {
            titleCountLabel.text = "14자 / 14자"
            textField.text = String(textField.text!.prefix(14))
            return
        }
    }
    
    @objc func contentTextDidChange(_ notification: NSNotification) {
        guard let textView = notification.object as? UITextView else { return }
        let textCount = textView.text.count
        contentCountLabel.text = "\(textCount)자 / 100자"
        if textCount > 100 {
            contentCountLabel.text = "100자 / 100자"
            textView.text = String(textView.text.prefix(100))
            return
        }
    }
    
    // MARK: - Custom Method
    
    private func showAlert() {
        let alertController = UIAlertController(title: "알림", message: "제목과 내용을 모두 적어주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension DetailDiaryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "내용을 입력하세요." {
            textView.text = ""
            textView.textColor = Palette.podaGray4.getColor()
        }
    }
}
