//
//  DiaryCollectionViewCell.swift
//  PODA
//
//  Created by 랑 on 2023/10/18.
//

import UIKit
import Then
import SnapKit

class DiaryCollectionViewCell: UICollectionViewCell, UIConfigurable {
    
    static let identifier = "DiaryCollectionViewCell"
    
    lazy var titleLabel = UILabel().then { 
        $0.setUpLabel(title: "나홀로\n인생네컷\n모음", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
        $0.textAlignment = .left
    }
    
    private let imageView = UIImageView().then {
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
        backgroundColor = Palette.podaBlue.getColor()
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        [titleLabel, imageView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { 
            $0.left.equalTo(8)
            $0.bottom.equalToSuperview().offset(-6)
        }
        
        imageView.snp.makeConstraints { 
            $0.top.equalToSuperview()
            $0.right.equalToSuperview().offset(-6)
        }
    }
}
