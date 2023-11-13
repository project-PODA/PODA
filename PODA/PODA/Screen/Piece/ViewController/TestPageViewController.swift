//
//  TestPageViewController.swift
//  PODA
//
//  Created by Kyle on 2023/10/18.
//

import UIKit
import SnapKit
import Then
import RealmSwift

class TestPageViewController: BaseViewController, UIConfigurable {
    
    var pieceData: Results<RealmPieceData>?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        loadImagesFromRealm()
    }
    
    func configUI() {
        view.backgroundColor = Palette.podaGray1.getColor()
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(200)
            $0.centerY.equalToSuperview()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func loadImagesFromRealm() {
        pieceData = RealmManager.shared.loadPieceData()
        
        for pieceData in pieceData! {
            print("Image Path: \(pieceData.imagePath ?? "No Image Path"), Piece Date: \(pieceData.pieceDate ?? Date())")
        }
        collectionView.reloadData()
    }
}

extension TestPageViewController: UICollectionViewDelegate {
    
}

extension TestPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = pieceData?.count ?? 0
        print("Number of items in section: \(itemCount)")
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("cell for item at : \(indexPath.item)")
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? Cell else {
            fatalError("Cell error")
        }
        
        // 이미지 메모리 전달하여 셀 구성
        if let pieceData = pieceData?[indexPath.item] {
            cell.configure(with: pieceData)
        }
        
        return cell
    }
}

extension TestPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.height
        let cellWidth: CGFloat = 100
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class Cell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderColor = Palette.podaBlack.getColor().cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.podaBlack.getColor()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(dateLabel)
        
        imageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(dateLabel.snp.top)
        }
        
        dateLabel.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
    
    func configure(with pieceInfo: RealmPieceData) {
        // 이미지 로드 및 설정
        guard let imagePath = pieceInfo.imagePath else {
            return
        }
        print("Image Path: \(imagePath)")
        
        
        if let image = UIImage(contentsOfFile: imagePath) {
            imageView.image = image
        } else {
            print("이미지 경로 없음: \(imagePath)")
        }
        
        
        // 추억 날짜 설정
        if let pieceDate = pieceInfo.pieceDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd"
            dateLabel.text = dateFormatter.string(from: pieceDate)
        }
    }
}
