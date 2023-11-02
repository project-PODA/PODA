//
//  PieceViewController.swift
//  PODA
//
//  Created by Kyle on 2023/10/16.
//

import UIKit
import Then
import SnapKit
import PhotosUI
import RealmSwift

class PieceViewController: BaseViewController, UIConfigurable {
        
    // MARK: UIComponents
    
    var isComeFromSaveDeleteVC = false
    var pieceList: Results<ImageMemory>?
    var indexPath = 0
    
    let cancelButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "뒤로", podaFont: .subhead3)
    }
    
    let nextButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "저장", podaFont: .subhead3)
    }
    
    let imageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.contentMode = .scaleAspectFit
    }
    
    let vectorIconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Vector")
    }
    
    let addToGalleryButton = UIButton().then {
        $0.setUpButton(title: "내 갤러리에서 추가", podaFont: .button1, cornerRadius: 23)
        $0.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaWhite.getColor()
    }
    
    let memoryDate = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.setUpLabel(title: "추억 날짜", podaFont: .subhead2)
    }
    
    let datePickerButton = UIButton().then {
        $0.setUpButton(title: "날짜 선택", podaFont: .body2, cornerRadius: 5)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
    }
    
//    let testPageButton = UIButton().then {
//        $0.setUpButton(title: "불러오기 테스트", podaFont: .body2, cornerRadius: 5)
//        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
//        $0.backgroundColor = Palette.podaGray5.getColor()
//    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        setAddTarget()
        setGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: Functions
    
    func configUI() {
        view.addSubview(cancelButton)
        view.addSubview(nextButton)
        view.addSubview(imageView)
        view.addSubview(vectorIconImage)
        view.addSubview(addToGalleryButton)
        view.addSubview(memoryDate)
        view.addSubview(datePickerButton)
//        view.addSubview(testPageButton)
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(59)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(59)
        }
        
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(107)
            $0.bottom.equalTo(memoryDate.snp.top).offset(-32)
        }
        
        vectorIconImage.snp.makeConstraints {
            $0.center.equalTo(imageView)
            $0.width.height.equalTo(70)
        }
        
        addToGalleryButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(vectorIconImage.snp.bottom).offset(25)
            $0.width.equalTo(152)
            $0.height.equalTo(45)
        }
        
        memoryDate.snp.makeConstraints {
            $0.bottom.equalTo(datePickerButton.snp.top).offset(-20)
            $0.left.equalToSuperview().offset(21)
        }
        
        datePickerButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(108)
            $0.height.equalTo(44)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
//        testPageButton.snp.makeConstraints {
//            $0.right.equalToSuperview().offset(-20)
//            $0.width.equalTo(108)
//            $0.height.equalTo(44)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
//        }
    }
    
    func setGesture() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        //imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGesture)
    }
    
    @objc func imageViewTapped() {
        addButtonTapped()
    }
    
    func setAddTarget() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addToGalleryButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
//        testPageButton.addTarget(self, action: #selector(testPageButtonTapped), for: .touchUpInside)
    }
    
    func getPieceDate(with imageMemory: ImageMemory) -> String {
        guard let memoryDate = imageMemory.memoryDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: memoryDate)
    }
    
    func updateUIForImageAvailability(hasImage: Bool) {
        vectorIconImage.isHidden = hasImage
        addToGalleryButton.isHidden = hasImage
    }
    
//    func saveImageToRealm(image: UIImage, date: Date?) {
//        guard let imageData = image.pngData(), let selectedDate = date else {
//            print("경고: 이미지 데이터 변환에 실패 또는 날짜 변환 실패")
//            return
//        }
//
//        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
//
//        do {
//            try imageData.write(to: fileURL)
//        } catch {
//            print("경고: 파일로 이미지 저장 실패: \(error.localizedDescription)")
//            return
//        }
//
//        RealmManager.shared.saveImageMemory(imagePath: fileURL.path, memoryDate: selectedDate)
//    }
    
    func saveImageToRealm(image: UIImage, date: Date?) {
        RealmManager.shared.saveImageMemory(image: image, memoryDate: date)
    }
    
    func showSaveConfirmationAlert() {
        guard let selectedImage = self.imageView.image,
              let selectedDateString = self.datePickerButton.title(for: .normal),
              let selectedDate = Date(dateString: selectedDateString, format: "yyyy. MM. dd") else {
            
            let failAlertController = UIAlertController(title: "알림", message: "이미지와 추억 날짜를 모두 설정해주세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            failAlertController.addAction(confirmAction)
            present(failAlertController, animated: true, completion: nil)
            
            return
        }
        
        let alertController = UIAlertController(title: "저장하시겠습니까?", message: nil, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }

            if !self.isComeFromSaveDeleteVC {
                self.saveImageToRealm(image: selectedImage, date: selectedDate)
                self.navigationController?.popViewController(animated: true)
            } else {
                // 날짜만 변경하는 메서드
                guard let imageMemory = self.pieceList?[indexPath] else { return }
                RealmManager.shared.updatePieceDate(imageMemory, selectedDate)
                print(selectedDate)
                self.pieceList = RealmManager.shared.loadImageMemories()
                
                // FIXME: - getPieceDate 호출 없이 selectedDate 로만 UI 업데이트하기
                guard let imageMemory = self.pieceList?[indexPath] else { return }
                guard let viewControllers = self.navigationController?.viewControllers else { return }
                for viewController in viewControllers {
                    if let viewController = viewController as? SaveDeleteViewController {
                        viewController.dateLabel.text = getPieceDate(with: imageMemory)
                        self.navigationController?.popToViewController(viewController, animated: true)
                    }
                }
            }
            print("pieceVC pop 될거야")
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextButtonTapped() {
        showSaveConfirmationAlert()
    }
    
//    @objc func testPageButtonTapped() {
//        present(TestPageViewController(), animated: true)
//    }
    
    @objc func addButtonTapped() {
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { [weak self] isAuthorized in
            DispatchQueue.main.async {
                if isAuthorized {
                    var configuration = PHPickerConfiguration()
                    configuration.filter = .images
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    self?.present(picker, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        
        if let title = datePickerButton.title(for: .normal),
           let currentDate = Date(dateString: title, format: "yyyy. MM. dd") {
            datePicker.date = currentDate
        }
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        let selectAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            let selectedDate = datePicker.date
            let formattedDate = selectedDate.getCurrentTime(Dataforamt: "yyyy. MM. dd")
            self?.datePickerButton.setTitle(formattedDate, for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PieceViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else {
            return
        }
        
        let selectedResult = results[0]
        
        selectedResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let error = error {
                print("이미지 로딩 중 오류: \(error.localizedDescription)")
            } else if let selectedImage = object as? UIImage {
                print("선택된 이미지의 너비 \(selectedImage.size.width)")
                DispatchQueue.main.async {
                    self?.imageView.image = selectedImage
                    self?.updateUIForImageAvailability(hasImage: true)
                }
            }
        }
    }
}

//@objc private func moveToCompletsButtonTapped() {
//    let pieceVC = PieceViewController()
//    navigationController?.pushViewController(pieceVC, animated: true)
//}
