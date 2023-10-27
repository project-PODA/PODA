//
//  SaveDeleteViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/22.
//

import UIKit

class SaveDeleteViewController: BaseViewController, UIConfigurable {
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    lazy var dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.06", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    lazy var imageView = UIImageView().then {
        $0.image = UIImage(named: "example") // 저장된 이미지 보여주기
    }
    
    private let saveButton = UIButton().then {
        $0.setUpButton(title: "save", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let deleteButton = UIButton().then {
        $0.setUpButton(title: "delete", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    var diaryName: String? //나중에 은서님 페이지에 이름 넘겨줄것..
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        let navigationBarStackView = UIStackView(arrangedSubviews: [backButton, dateLabel, addButton])
        navigationBarStackView.axis = .horizontal
        navigationBarStackView.alignment = .center
        navigationBarStackView.distribution = .equalSpacing
        
        let buttonStackView = UIStackView(arrangedSubviews: [saveButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillProportionally
        
        [navigationBarStackView, imageView, buttonStackView].forEach(view.addSubview)
        
        backButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        navigationBarStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(navigationBarStackView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            //$0.height.equalTo(512)
            $0.height.equalTo(view.frame.width * 1.25)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(72)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapAddButton() {
        // 선택된 Ratio의 만들기 페이지로 이동
    }
    
//    @objc func didTapSaveButton() {
//        // 저장되었습니다 토스트 메세지 띄우기 & 앨범에 이미지 추가
//        if let image = imageView.image {
//            UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
//        }
//    }
    
    @objc func didTapSaveButton() {
        // 앨범 권한을 먼저 체크하고 요청
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { (isAuthorized) in
            if isAuthorized {
                // 권한이 허용되면 이미지를 앨범에 저장
                if let image = self.imageView.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedImage(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            } else {
                // 권한이 거부되었을 경우 처리
            }
        }
    }
    
    @objc func didTapDeleteButton() {
        // 삭제되었습니다 토스트 메세지 띄우기 & 삭제하고 데이터 저장
    }
    
//    @objc func savedImage(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
//        if let error = error {
//            NSLog("Failed to save image. Error = \(error.localizedDescription)")
//            //                권한 허용 안함 상태일 때 설정에서 변경하라고 띄워주기
//            //                if isPermissionDenied, let vc = viewController {
//            //                    Dialog.presentPhotoPermission(vc)
//            //        }
//        } else {
//            // 토스트 메세지 띄우기
//            showToastMessage("성공적으로 저장되었습니다!", withDuration: 2.0, delay: 2.0)
//        }
//    }
    
    @objc func savedImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // 여기에 이미지가 성공적으로 저장되었거나, 실패했을 때의 처리를 작성합니다.
        if let error = error {
            print("사진 저장중 오류 발생: \(error)")
        } else {
            showToastMessage("성공적으로 저장되었습니다!", withDuration: 2.0, delay: 2.0)
        }
    }
    
    func showToastMessage(_ message : String, withDuration: Double, delay: Double) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 16.0
        toastLabel.clipsToBounds  =  true
        
        view.addSubview(toastLabel)
        
//        toastLabel.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
        
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

    
