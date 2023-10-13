//
//  UITableView + Extension.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit

extension UITableView {
    func setupableView<T: UITableViewCell>(delegate: UITableViewDelegate, dataSource: UITableViewDataSource, cellType: T.Type) {
        self.delegate = delegate
        self.dataSource = dataSource
        self.register(cellType, forCellReuseIdentifier: String(describing: cellType)) 
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
