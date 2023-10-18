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
    
    let realm = try! Realm()
    
    // MARK: UIComponents
    
    let cancelButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "취소", podaFont: .subhead2)
    }
    
    let nextButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "다음", podaFont: .subhead2)
    }
    
    let imageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.contentMode = .scaleAspectFit
    }
    
    let photoGalleryIconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "icon_photoGallery")
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
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        setAddTarget()
        setGesture()
        requestPhotoLibraryAccess()
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
        view.addSubview(photoGalleryIconImage)
        view.addSubview(addToGalleryButton)
        view.addSubview(memoryDate)
        view.addSubview(datePickerButton)
        
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
        
        photoGalleryIconImage.snp.makeConstraints {
            $0.center.equalTo(imageView)
            $0.width.height.equalTo(70)
        }
        
        addToGalleryButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoGalleryIconImage.snp.bottom).offset(25)
            $0.width.equalTo(152)
            $0.height.equalTo(45)
        }
        
        memoryDate.snp.makeConstraints {
            $0.bottom.equalTo(datePickerButton.snp.top).offset(-20)
            $0.left.equalToSuperview().offset(21)
        }
        
        //        datePickerButton.snp.makeConstraints {
        //            $0.left.equalToSuperview().offset(20)
        //            $0.width.equalTo(108)
        //            $0.height.equalTo(44)
        //            $0.bottom.equalToSuperview().offset(-104)
        //        }
        datePickerButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(108)
            $0.height.equalTo(44)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    func setGesture() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
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
    }
    
    func updateUIForImageAvailability(hasImage: Bool) {
        photoGalleryIconImage.isHidden = hasImage
        addToGalleryButton.isHidden = hasImage
    }
    
    func saveImageToRealm(image: UIImage, date: Date?) {
        guard let imageData = image.pngData(), let selectedDate = date else {
                print("경고: 이미지 데이터 변환에 실패 또는 날짜 변환 실패")
                return
            }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("경고: 파일로 이미지 저장 실패: \(error.localizedDescription)")
            return
        }
        
        let imageMemory = ImageMemory()
        imageMemory.imagePath = fileURL.path
        imageMemory.memoryDate = selectedDate
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(imageMemory)
                print("저장성공: \(imageMemory)")
            }
        } catch {
            print("Realm에 데이터를 추가하는 데 문제가 발생: \(error.localizedDescription)")
        }
    }
    
    func showSaveConfirmationAlert() {
        let alertController = UIAlertController(title: "저장하시겠습니까?", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            
            
            guard let selectedImage = self?.imageView.image, let selectedDate = self?.datePickerButton.title(for: .normal) else {
                self?.showAlert(title: "주의!", message: "이미지와 날짜가 모두 입력 되어야만 저장할 수 있습니다.")
                return
            }
            
            self?.saveImageToRealm(image: selectedImage, date: Date(dateString: selectedDate, format: "yyyy. MM. dd"))
            
            self?.navigationController?.popViewController(animated: true)
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
    
    @objc func addButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
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
            let formattedDate = selectedDate.GetCurrentTime(Dataforamt: "yyyy. MM. dd")
            self?.datePickerButton.setTitle(formattedDate, for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - 앨범 접근 권한

extension PieceViewController {
    func requestPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            // 이미 권한이 허용된 경우
            break
        case .denied, .restricted:
            // 권한이 거부되었거나 제한된 경우
            // 사용자에게 설정 앱으로 이동하여 권한을 변경하도록 요청
            showAlertToSettings()
        case .notDetermined:
            // 아직 권한을 요청하지 않은 경우
            PHPhotoLibrary.requestAuthorization { [weak self] (newStatus) in
                if newStatus == .authorized {
                    // 사용자가 권한을 허용한 경우
                } else {
                    // 사용자가 권한을 거부한 경우
                    // 사용자에게 설정 앱으로 이동하여 권한을 변경하도록 요청
                    self?.showAlertToSettings()
                }
            }
        default:
            break
        }
    }
    
    func showAlertToSettings() {
        let alertController = UIAlertController(
            title: "앨범 접근 권한이 필요합니다",
            message: "앨범 접근을 허용하려면 설정에서 권한을 변경해주세요.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (action) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
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
