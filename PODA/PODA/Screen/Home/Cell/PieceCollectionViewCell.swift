//
//  PieceCollectionViewCell.swift
//  PODA
//
//  Created by 랑 on 2023/10/18.
//

import UIKit
import Then
import SnapKit

class PieceCollectionViewCell: UICollectionViewCell, UIConfigurable {
    
    static let identifier = "PieceCollectionViewCell"
    
    private let pieceImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_bookMark")
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        backgroundColor = Palette.podaBlack.getColor()
//        layer.cornerRadius = 5
//        layer.masksToBounds = true
        
        addSubview(pieceImageView)
        
        pieceImageView.snp.makeConstraints { 
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
}

