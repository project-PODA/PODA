//
//  UICollectionView + Extension.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
//

import UIKit
extension UICollectionView{
    func setupBookTableView<T: UICollectionViewCell>(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource, cellType: T.Type) {
        self.delegate = delegate
        self.dataSource = dataSource
        self.register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
