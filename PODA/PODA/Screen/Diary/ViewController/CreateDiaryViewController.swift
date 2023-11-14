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
    var ratio: Ratio?
    var diaryName: String?
    
    private var textViewTapCount = 0
    
    private var currentImageView: UIImageView? {
        willSet {
            currentImageView?.layer.borderWidth = 0
            deleteButton.isHidden = true
        }
        
        didSet {
            if let imageView = currentImageView {
                setCurrentTextView(nil, tapCount: 0)
                deleteButton.isHidden = false
                
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = Palette.podaBlue.getColor().cgColor
            }
        }
    }
    
    private var currentTextView: UITextView? {
        willSet {
            currentTextView?.layer.borderWidth = 0
            deleteButton.isHidden = true
        }
        
        didSet {
            if let textView = currentTextView {
                setCurrentImageView(nil)
                deleteButton.isHidden = false
                
                if textViewTapCount == 1 {
                    textView.layer.borderWidth = 2
                    textView.layer.borderColor = Palette.podaBlue.getColor().cgColor
                } else if textViewTapCount == 2 {
                    textView.layer.borderWidth = 0
                    textView.becomeFirstResponder()
                    textViewTapCount = 0
                }
            }
        }
    }
    
    private var currentTextPosition: CGPoint?
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "취소", rightButtonTitle: "다음").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
    }
    
    private lazy var deleteButton = UIButton().then {
        var config = getButtonConfiguration(title: "선택 항목 삭제", iconName: nil)
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 3, leading: 11, bottom: 3, trailing: 11)
        $0.configuration = config
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.layer.cornerRadius = 11.5
        $0.isHidden = true
        $0.addTarget(self, action: #selector(touchUpDeleteButton), for: .touchUpInside)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.backgroundColor = Palette.podaBlack.getColor()
    }
    
    private lazy var diaryView = DiaryView().then {
        $0.clipsToBounds = true
        $0.didTap = { [weak self] touchedLocation in
            guard let self else { return }
            if let imageView = currentImageView, !imageView.frame.contains(touchedLocation) {
                setCurrentImageView(nil)
            } else if let textView = currentTextView, !textView.frame.contains(touchedLocation) {
                setCurrentTextView(nil, tapCount: 0)
            }
        }
        
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
//        $0.configuration = getButtonConfiguration(title: "스티커", iconName: "icon_sticker")
        $0.configuration = getButtonConfiguration(title: "추억 조각", iconName: "icon_pieceSticker")
        $0.addTarget(self, action: #selector(touchUpStickerButton), for: .touchUpInside)
    }
    
    private lazy var textButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "글 추가", iconName: "icon_text")
        $0.addTarget(self, action: #selector(touchUpTextButton), for: .touchUpInside)
    }
    
    private let decorateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 30
    }
    
    private lazy var decorateView = UIView().then {
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.addSubview(decorateStackView)
    }
    
    private let selectBackgroundColorView = ColorPaletteView().then {
        $0.isHidden = true
        $0.isHiddenFont(true)
    }
    
    private let selectTextColorView = ColorPaletteView().then {
        $0.isHidden = true
        $0.isHiddenFont(false)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindViewModel()
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
        hideKeyboardWhenTappedAround()
    }
    
    private func setupLayout() {
        [backgroundButton, galleryButton, stickerButton, textButton].forEach {
            decorateStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(diaryView)
        
        [navigationBar, deleteButton, 
         scrollView, decorateView,
         selectBackgroundColorView, selectTextColorView].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.centerX.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateView.snp.top)
        }
        
        diaryView.snp.makeConstraints {
            $0.top.equalTo(scrollView).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(scrollView)
            
            switch ratio {
            case .square:
                $0.width.height.equalTo(UIScreen.main.bounds.width)
            case .rectangle:
                $0.width.equalTo(UIScreen.main.bounds.width)
                $0.height.equalTo(UIScreen.main.bounds.width / 3 * 4)
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
            $0.centerX.centerY.equalTo(decorateView)
        }
        
        selectBackgroundColorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateStackView.snp.top)
            $0.height.equalTo(67)
        }
        
        selectTextColorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateStackView.snp.top)
            $0.height.equalTo(100)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        setCurrentImageView(nil)
        let diaryImage = diaryView.convertToPNGData()
        let detailDiaryViewController = DetailDiaryViewController(viewModel: viewModel)
        viewModel.setDiaryName(diaryName ?? "")
        viewModel.setPageInfo([PageInfo(imageData: diaryImage!, backgroundColor: diaryView.backgroundColor?.toHexString() ?? "")])
        navigationController?.pushViewController(detailDiaryViewController, animated: true)
    }
    
    // 배경색 변경 버튼을 눌렀을 때 실행되는 메소드
    @objc private func touchUpBackgroundButton() {
        UIView.animate(withDuration: 0.8) {
            self.selectBackgroundColorView.isHidden = self.isSelectedBackgroundButton
        }
        isSelectedBackgroundButton.toggle()
        
        // 앱에 기본으로 설정되어 있는 색상을 눌렀을 때
        selectBackgroundColorView.touchedColor = { color in
            self.diaryView.backgroundColor = color
        }
        
        // 사용자가 직접 커스텀한 색상을 눌렀을 때
        selectBackgroundColorView.changedCustomColor = { color in
            self.diaryView.backgroundColor = color
        }
        
        selectBackgroundColorView.touchedCustomColorButton = { colorPicker in
            self.present(colorPicker, animated: true)
        }
        
        selectBackgroundColorView.finishedCustomColor = {
            self.dismiss(animated: true)
        }
    }
    
    // 사진 추가 버튼을 눌렀을 때 실행되는 메소드
    @objc private func touchUpGalleryButton() {
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { (isAuthorized) in
            if isAuthorized {
                var configuration = PHPickerConfiguration()
                configuration.filter = .images
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    // 스티커(추억조각) 추가 버튼을 눌렀을 때 실행되는 메소드
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
        
        stickerViewController.touchedCell = { [weak self] image in
            stickerViewController.dismiss(animated: true)
            self?.viewModel.handleNewImage(image)
        }
    }
    
    // 텍스트 추가 버튼을 눌렀을 때 실행되는 메소드
    @objc private func touchUpTextButton() {
        var textView = UITextView()
        textView = addText(textView)
        selectTextColorView.isHidden = false
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            imageView.transform = imageView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
            
            setCurrentImageView(imageView)
        } else if let textView = recognizer.view as? UITextView {
            textView.resignFirstResponder()
            textView.transform = textView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
            
            setCurrentTextView(textView, tapCount: 1)
        }
    }
    
    @objc func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            imageView.transform = imageView.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            
            setCurrentImageView(imageView)
        } else if let textView = recognizer.view as? UITextView {
            textView.resignFirstResponder()
            textView.transform = textView.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            
            setCurrentTextView(textView, tapCount: 1)
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let translation = recognizer.translation(in: view)
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            recognizer.setTranslation(CGPoint.zero, in: view)
            
            setCurrentImageView(imageView)
        } else if let textView = recognizer.view as? UITextView {
            textView.resignFirstResponder()
            let translation = recognizer.translation(in: view)
            textView.center = CGPoint(x: textView.center.x + translation.x, y: textView.center.y + translation.y)
            recognizer.setTranslation(CGPoint.zero, in: view)
            
            setCurrentTextView(textView, tapCount: 1)
        }
    }
    
    @objc func didTapImageView(_ recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            setCurrentImageView(imageView)
        }
    }
    
    @objc private func didTapTextView(_ recognizer: UITapGestureRecognizer) {
        guard let textView = recognizer.view as? UITextView else { return }
        textViewTapCount += 1
        
        // 선택되어있는 textView가 있는데 바로 다른 textView를 선택했을 때 tapCount를 1로 바꾸고 currentTextView 설정을 해줌
        if currentTextView != textView {
            setCurrentTextView(textView, tapCount: 1)
        } else {
            setCurrentTextView(textView, tapCount: textViewTapCount)
        }
    }
    
    // 삭제 버튼 클릭시 현재 사용자가 편집 중인 (이미지 or 텍스트)가 삭제됨
    @objc func touchUpDeleteButton(_ sender: UIButton) {
        deleteButton.isHidden = true
        
        if let imageView = currentImageView {
            imageView.removeFromSuperview()
            setCurrentImageView(nil)
        } else if let textView = currentTextView {
            textView.removeFromSuperview()
            setCurrentTextView(nil, tapCount: 0)
        }
    }
    
    // MARK: - Custom Method
    
    func bindViewModel() {
        // newImage 변수 값이 바뀔 때마다 (즉, 새로운 이미지가 들어갈 때마다) addImage()를 실행시킴
        viewModel.newImage.addObserver { [weak self] image in
            guard let self = self, let image = image else { return }
            addImage(image)
        }
    }
    
    private func addImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        currentImageView = imageView
        
        imageView.frame = CGRect(x: diaryView.frame.width/4, y: diaryView.frame.height/4, width: 200, height: 200)
        diaryView.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        imageView.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
    }
    
    private func addText(_ textView: UITextView) -> UITextView {
        textView.becomeFirstResponder()
        textView.inputAccessoryView = selectTextColorView
        textView.backgroundColor = .clear
        textView.font = UIFont.podaFont(.body2)
        textView.textAlignment = .center
        textView.textContainer.maximumNumberOfLines = 4
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        
        textView.frame = CGRect(x: diaryView.frame.width/4, y: diaryView.frame.height/4, width: diaryView.frame.width/2, height: 100)
        diaryView.addSubview(textView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        tapGesture.numberOfTapsRequired = 1
        textView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        textView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        textView.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        textView.addGestureRecognizer(panGesture)
        
        return textView
    }
    
    private func setCurrentImageView(_ imageView: UIImageView?) {
        currentImageView = imageView
    }
    
    private func setCurrentTextView(_ textView: UITextView?, tapCount: Int) {
        textViewTapCount = tapCount
        currentTextView = textView
    }
    
    private func getButtonConfiguration(title: String, iconName: String?) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString.init(title)
        titleAttr.foregroundColor = Palette.podaWhite.getColor()
        titleAttr.font = UIFont.podaFont(.subhead1)
        config.attributedTitle = titleAttr
        
        if let iconName = iconName {
            config.image = UIImage(named: iconName)
            config.imagePlacement = .top
            config.imagePadding = 10
        }
        
        return config
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
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.viewModel.handleNewImage(selectedImage)
                }
            }
        }
    }
}

//MARK: - UITextViewDelegate

extension CreateDiaryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        setCurrentTextView(textView, tapCount: 2)
        selectTextColorView.isHidden = false
        
        currentTextPosition = textView.frame.origin
        
        textView.frame = CGRect(x: diaryView.frame.width/4, y: diaryView.frame.height/4, width: diaryView.frame.width/2, height: 100)
        
        selectTextColorView.touchedColor = { color in
            textView.tintColor = color
            textView.textColor = color
        }
        
        selectTextColorView.touchedCustomColorButton = { colorPicker in
            textView.resignFirstResponder()
            self.present(colorPicker, animated: true)
        }
        
        selectTextColorView.changedCustomColor = { color in
            textView.textColor = color
        }
        
        selectTextColorView.touchedFont = { font in
            textView.font = font
        }
        
        selectTextColorView.finishedCustomColor = {
            textView.becomeFirstResponder()
            self.dismiss(animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        deleteButton.isHidden = true
        textView.sizeToFit()
        textView.frame.origin = currentTextPosition ?? CGPoint()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else { return true }
        let newLength = currentText.count + text.count - range.length
        return newLength <= 50
    }
}

