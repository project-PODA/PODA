//
//  SaveDeleteViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/22.
//

import UIKit
import RealmSwift
import SnapKit

class SaveDeleteViewController: BaseViewController, UIConfigurable {
    
    static let deleteDiaryNotificationName = NSNotification.Name("deleteDiary")
    
    var diaryData : DiaryData?
    var ratio: String?
    
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    var isDiaryImage = true
    var pieceList: Results<ImageMemory>?
    var indexPath = 0
    //var diaryName: String? // 나중에 은서님 페이지에 이름 넘겨줄것.. (페이지 추가할 때?)
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    lazy var dateLabel = UILabel().then {
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    // FIXME: - 페이지 추가 기능 구현 시 tintColor podaWhite로
    lazy var addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        //$0.tintColor = Palette.podaWhite.getColor()
        $0.tintColor = Palette.podaBlack.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    lazy var editButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_editCalendar"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }
    
    lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var saveButton = UIButton().then {
        $0.setUpButton(title: "save", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    private lazy var deleteButton = UIButton().then {
        $0.setUpButton(title: "delete", podaFont: .head1)
        $0.titleLabel?.textColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [saveButton, deleteButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 128
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var navigationBarStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, dateLabel, addButton, editButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
//        🔫 save, delete 버튼 레이아웃 공부
//        let topBorder = UIView()
//        topBorder.backgroundColor = .red // 또는 원하는 색상으로 변경
//        view.addSubview(topBorder)
//        topBorder.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(2) // 테두리 두께
//        }
//        
//        let bottomBorder = UIView()
//        bottomBorder.backgroundColor = .red // 또는 원하는 색상으로 변경
//        view.addSubview(bottomBorder)
//        bottomBorder.snp.makeConstraints { make in
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(2) // 테두리 두께
//        }
    }
//    
//    🔫 save, delete 버튼 레이아웃 공부
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        let safeAreaTop: CGFloat = self.view.safeAreaInsets.top
//        let safeAreaBottom: CGFloat = self.view.safeAreaInsets.bottom
//        let totalHeight: CGFloat = self.view.frame.height
//        let imageViewHeight: CGFloat = self.imageView.frame.height
//        let navigationBarHeight: CGFloat = navigationBarStackView.frame.height
//        let padding: CGFloat = 24
//        
//        self.buttonStackView.snp.remakeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.centerY.equalTo(self.imageView.snp.bottom).offset((totalHeight - safeAreaTop - navigationBarHeight - imageViewHeight - safeAreaBottom - padding) / 2)
//        }
//    }
     
    func configUI() {
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
            
            if diaryData?.ratio == "square" {
                $0.width.height.equalTo(UIScreen.main.bounds.width)
                
            } else {
                $0.width.equalTo(UIScreen.main.bounds.width)
                $0.height.equalTo(UIScreen.main.bounds.width * 4 / 3)
            }
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(imageView.snp.bottom).offset(24)
        }
        
        DispatchQueue.main.async {
            let safeAreaTop: CGFloat = self.view.safeAreaInsets.top
            let safeAreaBottom: CGFloat = self.view.safeAreaInsets.bottom
            let totalHeight: CGFloat = self.view.frame.height
            let imageViewHeight: CGFloat = self.imageView.frame.height
            let navigationBarHeight: CGFloat = self.navigationBarStackView.frame.height
            let padding: CGFloat = 24
            
            self.buttonStackView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalTo(self.imageView.snp.bottom).offset((totalHeight - safeAreaTop - navigationBarHeight - imageViewHeight - safeAreaBottom - padding) / 2)
            }
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
        pieceVC.pieceList = pieceList
        pieceVC.indexPath = indexPath
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
            print(isDiaryImage)
            if isDiaryImage {
                guard let diaryName = diaryData?.diaryName else { return }
                firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
                    if error == .none, let viewControllers = self.navigationController?.viewControllers {
                        // 다이어리 이미지 여러장인 경우에만 삭제되었습니다 토스트 메세지 띄우면서 다음이미지를 앞으로 당기기
                        // self.showToastMessage("삭제되었습니다.", withDuration: 0.8, delay: 0.8)
                        
                        // deleteDiaryImage 후 다이어리 이미지 갯수 = 0 인 경우 deleteDiary 호출 후 HomeViewController로 이동
                        self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
                            for viewController in viewControllers {
                                if let viewController = viewController as? BaseTabbarController {
                                    NotificationCenter.default.post(
                                        name: SaveDeleteViewController.deleteDiaryNotificationName,
                                        object: DiaryData(
                                            diaryName: diaryName,
                                            diaryImageList: self.diaryData?.diaryImageList ?? [],
                                            createDate: self.diaryData?.createDate ?? "",
                                            ratio: self.diaryData?.ratio ?? "",
                                            description: self.diaryData?.description ?? "")
                                    )
                                    self.navigationController?.popToViewController(viewController, animated: true)
                                    break
                                }
                            }
                        }
                        // self.getBackToHome() > 이거 주석 안하면 updateUI이 handleDeleteNotification보다 먼저 실행돼서 삭제가 반영이 안됨
                    }
                }
            } else {
                pieceList = RealmManager.shared.loadImageMemories()
                guard let imageMemory = self.pieceList?[indexPath] else { return }
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
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for viewController in viewControllers {
            if let viewController = viewController as? BaseTabbarController {
                self.navigationController?.popToViewController(viewController, animated: true)
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


