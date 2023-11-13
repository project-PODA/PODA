//
//  MorePieceCollectionViewCell.swift
//  PODA
//
//  Created by 랑 on 2023/11/03.
//

import UIKit
import Then
import SnapKit

class MorePieceCollectionViewCell: UICollectionViewCell, UIConfigurable {
    
    static let identifier = "MorePieceCollectionViewCell"
    
    lazy var pieceImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        addSubview(pieceImageView)
        
        pieceImageView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
}
