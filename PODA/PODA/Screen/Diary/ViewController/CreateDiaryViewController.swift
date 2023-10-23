//
//  CreateDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then
import PhotosUI

class CreateDiaryViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    // MARK: - Properties
    
    var viewModel: CreateDiaryViewModel!
    var ratio: Ratio!
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "취소", rightButtonTitle: "다음").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Palette.podaBlack.getColor()
    }
    
    private let diaryView = UIView().then {
        $0.backgroundColor = Palette.podaGray4.getColor()
    }
    
    private let pageLabel = UILabel().then {
        $0.setUpLabel(title: "페이지 목록", podaFont: .subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var backgroundButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "배경", iconName: "icon_background")
        $0.addTarget(self, action: #selector(touchUpBackgroundButton), for: .touchUpInside)
    }
    private var isSelectedBackgroundButton = false
    
    private lazy var galleryButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "사진", iconName: "icon_gallery")
        $0.addTarget(self, action: #selector(touchUpGalleryButton), for: .touchUpInside)
    }
    
    private lazy var stickerButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "스티커", iconName: "icon_sticker")
        $0.addTarget(self, action: #selector(touchUpStickerButton), for: .touchUpInside)
    }
    
    private lazy var textButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "글 추가", iconName: "icon_text")
        $0.addTarget(self, action: #selector(touchUpTextButton), for: .touchUpInside)
    }
    
    private let decorateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 30
    }
    
    private lazy var decorateView = UIView().then {
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.addSubview(decorateStackView)
    }
    
    private let selectBackgroundColorView = ColorPaletteView().then {
        $0.isHidden = true
    }
    
    private let selectTextColorView = ColorPaletteView().then {
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    init(viewModel: CreateDiaryViewModel, ratio: Ratio) {
        self.viewModel = viewModel
        self.ratio = ratio
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
        [backgroundButton, galleryButton, stickerButton, textButton].forEach {
            decorateStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(diaryView)
        
        [navigationBar, scrollView, decorateView, selectBackgroundColorView, selectTextColorView].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateView.snp.top)
        }
        
        diaryView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            
            switch ratio {
            case .square:
                $0.top.equalTo(scrollView).offset(30)
                $0.width.height.equalTo(393)
            case .rectangle:
                $0.top.equalTo(scrollView)
                $0.width.equalTo(393)
                $0.height.equalTo(524)
            case .none:
                $0.width.height.equalTo(393)
            }
        }
        
        decorateView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(80)
        }
        
        decorateStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(decorateView).inset(40)
            $0.centerY.equalTo(decorateView)
        }
        
        selectBackgroundColorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateStackView.snp.top)
            $0.height.equalTo(67)
        }
        
        selectTextColorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateStackView.snp.top)
            $0.height.equalTo(67)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        let viewController = DetailDiaryViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func touchUpAddPageButton() {
        
    }
    
    @objc private func touchUpBackgroundButton() {
        UIView.animate(withDuration: 0.8) {
            self.selectBackgroundColorView.isHidden = self.isSelectedBackgroundButton
        }
        isSelectedBackgroundButton.toggle()
    }
    
    @objc private func touchUpGalleryButton() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func touchUpStickerButton() {
        let stickerViewController = StickerViewController()
        stickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheetPresentationController = stickerViewController.presentationController as? UISheetPresentationController {
            sheetPresentationController.detents = [.custom { _ in
                return 700
            }]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.largestUndimmedDetentIdentifier = .medium
        }
        
        present(stickerViewController, animated: true)
        
        stickerViewController.touchedCell = { image in
            stickerViewController.dismiss(animated: true)
            self.addImage(image)
        }
    }
    
    @objc private func touchUpTextButton() {
        addText()
        selectTextColorView.isHidden = false
    }
    
    // MARK: - Custom Method
    
    func bindViewModel() {
        
    }
    
    private func getButtonConfiguration(title: String, iconName: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString.init(title)
        titleAttr.foregroundColor = Palette.podaWhite.getColor()
        titleAttr.font = UIFont.podaFont(.subhead1)
        config.attributedTitle = titleAttr
        config.image = UIImage(named: iconName)
        config.imagePlacement = .top
        config.imagePadding = 10
        
        return config
    }
    
    private func addImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        diaryView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.center.equalTo(diaryView)
            $0.width.height.equalTo(200)
        }
    }
    
    private func addText() {
        let textField = UITextField()
        textField.becomeFirstResponder()
        textField.inputAccessoryView = selectTextColorView
        textField.delegate = self
        diaryView.addSubview(textField)
        textField.snp.makeConstraints {
            $0.center.equalTo(diaryView)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CreateDiaryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else { return }
        
        let selectedResult = results[0]
        
        selectedResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                print("이미지 로딩 중 오류: \(error.localizedDescription)")
            } else if let selectedImage = object as? UIImage {
                DispatchQueue.main.async {
                    self?.addImage(selectedImage)
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate

extension CreateDiaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        selectTextColorView.isHidden = true
        return true
    }
}

