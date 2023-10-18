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

class PieceViewController: BaseViewController, UIConfigurable {
    
    let cancelButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "취소", podaFont: .subhead2)
    }
    
    let nextButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.setUpButton(title: "다음", podaFont: .subhead2)
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.contentMode = .scaleAspectFit
    }
    
    let photoGalleryIconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "icon_photoGallery")
    }
    
    let addToGalleryButton = UIButton().then {
        $0.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaWhite.getColor()
        $0.setUpButton(title: "내 갤러리에서 추가", podaFont: .button1)
    }
    
    let memoryDate = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.setUpLabel(title: "추억 날짜", podaFont: .subhead2)
    }
    
    let datePickerButton = UIButton().then {
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.setUpButton(title: "날짜 선택", podaFont: .body2)
    }
    
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
            $0.bottom.equalToSuperview().offset(-216)
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
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(21)
        }
        
        datePickerButton.snp.makeConstraints {
            $0.top.equalTo(memoryDate.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(108)
            $0.height.equalTo(44)
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
    
    func showSaveConfirmationAlert() {
        let alertController = UIAlertController(title: "저장하시겠습니까?", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
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
           let currentDate = Date(dateString: title, format: "yyyy-MM-dd") {
            datePicker.date = currentDate
        }
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        let selectAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            let selectedDate = datePicker.date
            let formattedDate = selectedDate.GetCurrentTime(Dataforamt: "yyyy-MM-dd")
            self?.datePickerButton.setTitle(formattedDate, for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

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
