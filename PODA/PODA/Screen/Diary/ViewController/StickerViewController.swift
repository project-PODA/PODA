//
//  StickerViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/21.
//

import UIKit
import SnapKit
import Then

class StickerViewController: BaseViewController, UIConfigurable {

    // MARK: - Properties
    
    private let stickerList: [UIImage?] = [UIImage(named: "image_profile"), UIImage(named: "image_profile"), UIImage(named: "image_profile")]
    private let pieceList: [UIImage?] = [UIImage(named: "image_profile"), UIImage(named: "image_profile")]
    
    private lazy var cancelButton = UIButton().then {
        $0.setUpButton(title: "Cancel", podaFont: .body2)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
    }
    
    private lazy var segmentedControl = UISegmentedControl(items: ["스티커", "추억조각"]).then {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(segmentedControlSelected), for: .valueChanged)
    }
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 30
        $0.minimumInteritemSpacing = 30
        $0.itemSize = CGSize(width: 130, height: 130)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    // MARK: - InitUI
    
    func configUI() {
        view.backgroundColor = Palette.podaWhite.getColor()
        setupLayout()
        setupCollectionView()
    }
    
    private func setupLayout() {
        [cancelButton, segmentedControl, collectionView].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(StickerCollectionViewCell.nib(), forCellWithReuseIdentifier: StickerCollectionViewCell.identifier)
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func segmentedControlSelected() {
        switch segmentedControl.selectedSegmentIndex {
        default:
            collectionView.reloadData()
        }
    }
    
    // MARK: - Custom Method

}

//MARK: - UICollectionViewDataSource

extension StickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return stickerList.count
        case 1:
            return pieceList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionViewCell.identifier, for: indexPath) as? StickerCollectionViewCell
        else { return UICollectionViewCell() }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.setImage(stickerList[indexPath.item] ?? UIImage())
            cell.imageView.contentMode = .scaleAspectFit
        case 1:
            cell.setImage(pieceList[indexPath.item] ?? UIImage())
            cell.imageView.contentMode = .scaleAspectFit
        default:
            break
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension StickerViewController: UICollectionViewDelegate {
    
}
