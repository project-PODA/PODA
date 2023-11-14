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
    
    static let modifyPieceDateNotificationName = NSNotification.Name("modifyPieceDate")
        
    // MARK: UIComponents
    
    var isComeFromSaveDeleteVC = false
    var pieceList: [PieceData] = []
    var realmPieceList: [RealmPieceData] = []
    var pieceIndex: Int?
    
    let cancelButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "취소", podaFont: .subhead3)
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
    
    let pieceDate = UILabel().then {
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
        view.addSubview(pieceDate)
        view.addSubview(datePickerButton)
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(cancelButton.snp.bottom).offset(28)
            $0.bottom.equalTo(pieceDate.snp.top).offset(-32)
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
        
        pieceDate.snp.makeConstraints {
            $0.bottom.equalTo(datePickerButton.snp.top).offset(-20)
            $0.left.equalToSuperview().offset(21)
        }
        
        datePickerButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(108)
            $0.height.equalTo(44)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        let currentDate = Date()
        let formattedDate = currentDate.getCurrentTime(Dataforamt: "yyyy.MM.dd")
        datePickerButton.setTitle(formattedDate, for: .normal)
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
        datePickerButton.addTarget(self, action: #selector(showCalendarModal), for: .touchUpInside)
    }
    
    func updateUIForImageAvailability(hasImage: Bool) {
        vectorIconImage.isHidden = hasImage
        addToGalleryButton.isHidden = hasImage
    }
    
    func saveImageToRealm(image: UIImage, date: Date?) {
        RealmManager.shared.savePieceData(image: image, pieceDate: date)
    }
    
    func showSaveConfirmationAlert() {
        guard let selectedImage = self.imageView.image,
              let selectedDateString = self.datePickerButton.title(for: .normal),
              let selectedDate = Date(dateString: selectedDateString, format: "yyyy.MM.dd") else {
            
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
                let targetId = pieceList[pieceIndex ?? 0].id
                if let targetIndex = realmPieceList.firstIndex(where: { $0.id == targetId }) {
                    let pieceInfo = realmPieceList[targetIndex]
                    RealmManager.shared.updatePieceDate(pieceInfo, selectedDate)
                } else {
                    print("targetId와 일치하는 realmPieceList.id가 없어!!")
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd"
                let modifiedDate = dateFormatter.string(from: selectedDate)
                
//                print("pieceVC에서 전달하는 targetId: \(targetId), modifiedDate: \(modifiedDate)")
                NotificationCenter.default.post(
                    name: PieceViewController.modifyPieceDateNotificationName,
                    object: (targetId, modifiedDate))
                
                guard let viewControllers = self.navigationController?.viewControllers else { return }
                for viewController in viewControllers {
                    if let viewController = viewController as? SaveDeleteViewController {
                        viewController.dateLabel.text = modifiedDate
                        self.navigationController?.popToViewController(viewController, animated: true)
                    }
                }
            }
            print("pieceVC pop 될거야")
        }

        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func nextButtonTapped() {
        showSaveConfirmationAlert()
    }
    
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
    
//    @objc func showDatePicker() {
//        let datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.locale = Locale(identifier: "ko_KR")
//        
//        if let title = datePickerButton.title(for: .normal),
//           let currentDate = Date(dateString: title, format: "yyyy.MM.dd") {
//            datePicker.date = currentDate
//        }
//        
//        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
//        alertController.view.addSubview(datePicker)
//        
//        datePicker.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//        }
//        
//        let selectAction = UIAlertAction(title: "확인", style: .cancel) { [weak self] _ in
//            let selectedDate = datePicker.date
//            let formattedDate = selectedDate.getCurrentTime(Dataforamt: "yyyy.MM.dd")
//            self?.datePickerButton.setTitle(formattedDate, for: .normal)
//        }
//        
//        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
//        
//        alertController.addAction(selectAction)
//        alertController.addAction(cancelAction)
//        
//        present(alertController, animated: true, completion: nil)
//    }
    
    @objc func showCalendarModal() {
        let calendarViewController = UIViewController()
        calendarViewController.view.backgroundColor = Palette.podaWhite.getColor()
        calendarViewController.modalPresentationStyle = .pageSheet
        
        if let sheetPresentationController = calendarViewController.presentationController as? UISheetPresentationController {
            sheetPresentationController.detents = [.custom { _ in
                return UIScreen.main.bounds.height / 2
            }]
            sheetPresentationController.prefersGrabberVisible = true
        }
                
        let calendarView = UICalendarView()
//        calendarView.delegate = self
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        calendarViewController.view.addSubview(calendarView)
        
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        present(calendarViewController, animated: true)
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
                //print("선택된 이미지의 너비 \(selectedImage.size.width)")
                DispatchQueue.main.async {
                    self?.imageView.image = selectedImage
                    self?.updateUIForImageAvailability(hasImage: true)
                }
            }
        }
    }
}

extension PieceViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date)
        
        DispatchQueue.main.async {
            self.datePickerButton.setTitle(dateString, for: .normal)
        }
    }
}
