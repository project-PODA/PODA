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
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    // FIXME: - UIScreen.main.bounds.height * 5 / 7 따로 빼서 상수로 정의해두기
    private let diaryDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3
        let height = ((UIScreen.main.bounds.height * 5 / 7) - 12) / 2
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12.0  // 셀 옆 간격
        layout.minimumLineSpacing = 12.0  // 셀 위 아래 간격
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.register(DiaryDetailCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryDetailCollectionViewCell")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        diaryDetailCollectionView.delegate = self
        diaryDetailCollectionView.dataSource = self
    }

    func configUI() {
        [backButton, diaryDetailCollectionView].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        
        diaryDetailCollectionView.snp.makeConstraints { 
            $0.top.equalTo(backButton.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(UIScreen.main.bounds.height * 5 / 7)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension MoreDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDetailCollectionViewCell.identifier, for: indexPath) as? DiaryDetailCollectionViewCell else { return UICollectionViewCell() }
        
        cell.titleLabel.text = diaryList[indexPath.row].diaryName
        cell.gradientImageView.image = UIImage(data: diaryList[indexPath.row].diaryImageList[0])
        cell.dateLabel.text = diaryList[indexPath.row].createDate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let saveDeleteVC = SaveDeleteViewController()
        saveDeleteVC.dateLabel.text = diaryList[indexPath.row].createDate
        saveDeleteVC.diaryName = diaryList[indexPath.row].diaryName
        saveDeleteVC.imageView.image = UIImage(data: diaryList[indexPath.row].diaryImageList[0])
        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
}
