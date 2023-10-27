//
//  SaveDeleteViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/22.
//

import UIKit
import RealmSwift

class SaveDeleteViewController: BaseViewController, UIConfigurable {
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    var isDiaryImage = true
    var imageMemories: Results<ImageMemory>?
    var indexPath = 0
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    lazy var dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.06", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    lazy var addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    lazy var editButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_editCalendar"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
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
        print(navigationController?.viewControllers)
    }
    
    func configUI() {
        let navigationBarStackView = UIStackView(arrangedSubviews: [backButton, dateLabel, addButton, editButton])
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
        
        editButton.snp.makeConstraints {
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
    
    @objc func didTapEditButton() {
        let pieceVC = PieceViewController()
        pieceVC.vectorIconImage.isHidden = true
        pieceVC.addToGalleryButton.isHidden = true
        pieceVC.imageView.isUserInteractionEnabled = false
        pieceVC.isComeFromSaveDeleteVC = true
        pieceVC.imageView.image = imageView.image
        navigationController?.pushViewController(pieceVC, animated: true)
    }
    
    @objc func didTapSaveButton() {
        // 앨범 권한을 먼저 체크하고 요청
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { (isAuthorized) in
            if isAuthorized {
                // 권한이 허용되면 이미지를 앨범에 저장
                if let image = self.imageView.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedImage(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    @objc func didTapDeleteButton() {
        print("이미지 삭제")
        let alert = UIAlertController(title: "정말 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            guard let self else { return }
            print(indexPath)
            if isDiaryImage {
                guard let diaryName else { return }
                firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
                    if error == .none {
                        // 다이어리 이미지 여러장인 경우에만 삭제되었습니다 토스트 메세지 띄우면서 다음이미지를 앞으로 당기기
                        // self.showToastMessage("삭제되었습니다.", withDuration: 0.8, delay: 0.8)
                        // deleteDiaryImage 후 다이어리 이미지 = 0 인 경우 deleteDiary 호출 후 HomeViewController로 이동
                        self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
                            
                        }
                        self.getBackToHome()
                    }
                }
            } else {
                imageMemories = RealmManager.shared.loadImageMemories()
                guard let imageMemory = self.imageMemories?[indexPath] else { return }
                RealmManager.shared.deleteImageMemory(imageMemory)
                self.getBackToHome()
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func savedImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            NSLog("Failed to save image. Error = \(error.localizedDescription)")
        } else {
            showToastMessage("성공적으로 저장되었습니다!", withDuration: 0.8, delay: 0.8)
        }
    }
    
    func getBackToHome() {
        guard let viewControllerStack = self.navigationController?.viewControllers else { return }
        for viewController in viewControllerStack {
            if let homeVC = viewController as? BaseTabbarController {
                self.navigationController?.popToViewController(homeVC, animated: true)
            }
        }
    }
    
    func showToastMessage(_ message: String, withDuration: Double, delay: Double) {
        let toastLabel = UILabel(frame: CGRect(x: self.imageView.center.x - 82, y: self.imageView.center.y - 18, width: 164, height: 36))
        toastLabel.setUpLabel(title: message, podaFont: .caption)
        toastLabel.textColor = Palette.podaWhite.getColor()
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.7)
        toastLabel.layer.cornerRadius = 7.0
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


