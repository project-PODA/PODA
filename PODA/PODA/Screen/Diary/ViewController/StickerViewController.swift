//
//  StickerViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/21.
//

import UIKit
import SnapKit
import Then
import RealmSwift

class StickerViewController: BaseViewController, UIConfigurable {
    
    // MARK: - Properties
    
    //    private let stickerList: [UIImage?] = [UIImage(named: "image_profile"), UIImage(named: "image_profile"), UIImage(named: "image_profile")]
    private var pieceList: Results<ImageMemory>?
    
    var touchedCell: ((_ image: UIImage)->())?
    
    private lazy var cancelButton = UIButton().then {
        $0.setUpButton(title: "Cancel", podaFont: .body2)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
    }
    
    //    private lazy var segmentedControl = UISegmentedControl(items: ["스티커", "추억조각"]).then {
    //        $0.selectedSegmentIndex = 0
    //        $0.addTarget(self, action: #selector(segmentedControlSelected), for: .valueChanged)
    //    }
    
    private let emptyPieceLabel = UILabel().then {
        $0.setUpLabel(title: "추억조각이 없습니다\n홈에서 추가해주세요!", podaFont: .caption)
        $0.numberOfLines = 2
        $0.textColor = Palette.podaGray3.getColor()
        $0.textAlignment = .center
    }
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 30
        $0.minimumInteritemSpacing = 30
        let size = (UIScreen.main.bounds.width - 70) / 2
        $0.itemSize = CGSize(width: size, height: size)
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
        loadPieceDataFromRealm()
    }
    
    private func setupLayout() {
        [cancelButton, emptyPieceLabel, collectionView].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        emptyPieceLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
//        segmentedControl.snp.makeConstraints {
//            $0.top.equalToSuperview().inset(20)
//            $0.centerX.equalToSuperview()
//        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
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
        collectionView.reloadData()
        
//        switch segmentedControl.selectedSegmentIndex {
//        default:
//            collectionView.reloadData()
//        }
    }
    
    // MARK: - Custom Method
    
    func loadPieceDataFromRealm() {
        pieceList = RealmManager.shared.loadImageMemories()
        guard let pieceCount = pieceList?.count else { return }
        print("추억 조각 갯수 = \(pieceCount)")
        if pieceCount != 0 {
            // 등록된 추억 조각이 있는 경우
            emptyPieceLabel.isHidden = true
            collectionView.isHidden = false
            
            collectionView.reloadData()
        } else {
            // 등록된 추억 조각이 없는 경우
            emptyPieceLabel.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    func getPieceImage(with imageMemory: ImageMemory) -> UIImage {
        guard let fileName = imageMemory.imagePath,
              let documentDirectory = RealmManager.shared.getDocumentDirectory() else {
            return UIImage()
        }
        
        let filePath = documentDirectory.appendingPathComponent(fileName).path
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            print("이미지 로딩 실패: \(error.localizedDescription)")
        }
        return UIImage()
    }
}

//MARK: - UICollectionViewDataSource

extension StickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pieceCount = pieceList?.count else { return 0 }
        return pieceCount
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            return stickerList.count
//        case 1:
//            return pieceList.count
//        default:
//            return 0
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionViewCell.identifier, for: indexPath) as? StickerCollectionViewCell
        else { return UICollectionViewCell() }
        
        guard let pieceImage = pieceList?[indexPath.item] else { return UICollectionViewCell() }
        cell.setImage(getPieceImage(with: pieceImage))
        
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            cell.setImage(stickerList[indexPath.item] ?? UIImage())
//        case 1:
//            cell.setImage(pieceList[indexPath.item] ?? UIImage())
//        default:
//            break
//        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension StickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pieceImage = pieceList?[indexPath.item] else { return }
        touchedCell?(getPieceImage(with: pieceImage))
        
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            touchedCell?(stickerList[indexPath.item] ?? UIImage())
//        case 1:
//            touchedCell?(pieceList[indexPath.item] ?? UIImage())
//        default:
//            break
//        }
    }
}
