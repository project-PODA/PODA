//
//  ColorPaletteView.swift
//  PODA
//
//  Created by 배은서 on 2023/10/20.
//

import UIKit
import SnapKit
import Then

class ColorPaletteView: UIView {
    
    // MARK: - Properties
    private var colorList: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .cyan, .magenta]
    
    private let customColorButton = UIColorWell()
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 5
        $0.itemSize = CGSize(width: 37, height: 37)
    }
    private lazy var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    private func configUI() {
        backgroundColor = .black
        setupLayout()
        setupCollectionView()
    }
    
    private func setupLayout() {
        [customColorButton, colorCollectionView].forEach {
            addSubview($0)
        }
        
        customColorButton.snp.makeConstraints {
            $0.centerY.equalTo(colorCollectionView)
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(41)
        }
        
        colorCollectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(customColorButton.snp.trailing).offset(5)
            $0.trailing.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.nib(), forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        colorCollectionView.backgroundColor = .clear
    }
    
    // MARK: - Custom Method
    
}

//MARK: - UICollectionViewDataSource

extension ColorPaletteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.layer.cornerRadius = 18.5
        cell.setColor(colorList[indexPath.item])
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension ColorPaletteView: UICollectionViewDelegate {
    
}
