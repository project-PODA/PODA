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
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let diaryDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3
        layout.itemSize = CGSize(width: width, height: 320) // 셀 사이즈
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
        view.addSubview(backButton)
        view.addSubview(diaryDetailCollectionView)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        
        diaryDetailCollectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            //make.height.equalTo(480)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

}

extension MoreDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDetailCollectionViewCell.identifier, for: indexPath) as? DiaryDetailCollectionViewCell else { return UICollectionViewCell() }
        
        //titleLabel.text = indexPath.row의 title
        //cell.imageView.image = imageList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let editSaveViewController = SaveDeleteViewController()
        navigationController?.pushViewController(editSaveViewController, animated: true)
    }
}
