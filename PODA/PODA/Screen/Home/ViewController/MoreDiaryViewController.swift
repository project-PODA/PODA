//
//  MoreDiaryViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/18.
//

import UIKit
import Then
import SnapKit

class MoreDiaryViewController: BaseViewController, UIConfigurable {
    
    var diaryList : [DiaryData] = []
    var diaryName: String?
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_trash"), for: .normal)
        $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    let emptyMoreDiaryLabel = UILabel().then {
        $0.setUpLabel(title: "아직 다이어리가 없어요\n홈으로 돌아가 생성하기를 통해 만들어보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    // FIXME: - UIScreen.main.bounds.height * 5 / 7 따로 빼서 상수로 정의해두기
    let moreDiaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3
        let height = ((UIScreen.main.bounds.height * 5 / 7) - 12) / 2
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12.0  // 셀 옆 간격
        layout.minimumLineSpacing = 12.0  // 셀 위 아래 간격
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.register(MoreDiaryCollectionViewCell.self, forCellWithReuseIdentifier: "MoreDiaryCollectionViewCell")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        moreDiaryCollectionView.delegate = self
        moreDiaryCollectionView.dataSource = self
    }

    func configUI() {
        [backButton, deleteButton, emptyMoreDiaryLabel, moreDiaryCollectionView].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        
        emptyMoreDiaryLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        moreDiaryCollectionView.snp.makeConstraints { 
            $0.top.equalTo(backButton.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(UIScreen.main.bounds.height * 5 / 7)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapDeleteButton() {
        // 삭제하는 로직은 delegate에
//        diaryList[indexPath.row].diaryName
//        guard let self else { return }
//        print(isDiaryImage)
//        if isDiaryImage {
//            guard let diaryName else { return }
//            firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
//                if error == .none {
//                    // 다이어리 이미지 여러장인 경우에만 삭제되었습니다 토스트 메세지 띄우면서 다음이미지를 앞으로 당기기
//                    // self.showToastMessage("삭제되었습니다.", withDuration: 0.8, delay: 0.8)
//                    // deleteDiaryImage 후 다이어리 이미지 = 0 인 경우 deleteDiary 호출 후 HomeViewController로 이동
//                    self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
//                        
//                    }
//                    self.getBackToHome()
//                }
//            }
//    }
//    let alert = UIAlertController(title: "정말 삭제하시겠습니까?", message: "선택된 다이어리는 영구적으로 삭제됩니다.", preferredStyle: .alert)
//    let confirmAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
//        guard let self else { return }
//        guard let diaryName else { return }
//        firebaseImageManager.deleteDiaryImage(diaryName: diaryName) { error in
//            if error == .none {
//                // 다이어리 이미지 여러장인 경우에만 삭제되었습니다 토스트 메세지 띄우면서 다음이미지를 앞으로 당기기
//                // self.showToastMessage("삭제되었습니다.", withDuration: 0.8, delay: 0.8)
//                // deleteDiaryImage 후 다이어리 이미지 = 0 인 경우 deleteDiary 호출 후 HomeViewController로 이동
//                self.firebaseDBManager.deleteDiary(diaryName: diaryName) { error in
//                    
//                }
//                self.getBackToHome()
//            }
//        }
//    }
//    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//    
//    alert.addAction(confirmAction)
//    alert.addAction(cancelAction)
//    
//    self.present(alert, animated: true, completion: nil)
    }
}

extension MoreDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoreDiaryCollectionViewCell.identifier, for: indexPath) as? MoreDiaryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.gradientImageView.image = UIImage(data: diaryList[indexPath.row].diaryImageList[0])
        cell.titleLabel.setUpLabel(title: diaryList[indexPath.row].diaryName, podaFont: .head1)
        cell.dateLabel.setUpLabel(title: diaryList[indexPath.row].createDate, podaFont: .subhead2)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let saveDeleteVC = SaveDeleteViewController()
        saveDeleteVC.dateLabel.text = diaryList[indexPath.row].createDate
        saveDeleteVC.diaryName = diaryList[indexPath.row].diaryName
        saveDeleteVC.imageView.image = UIImage(data: diaryList[indexPath.row].diaryImageList[0])
        saveDeleteVC.isDiaryImage = true
        saveDeleteVC.editButton.isHidden = true
        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
}
