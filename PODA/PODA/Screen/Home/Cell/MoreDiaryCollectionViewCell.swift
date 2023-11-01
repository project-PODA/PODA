//
//  MoreDiaryCollectionViewCell.swift
//  PODA
//
//  Created by 랑 on 2023/10/20.
//

import UIKit
import Then
import SnapKit

class MoreDiaryCollectionViewCell: UICollectionViewCell, UIConfigurable {
    
    static let identifier = "MoreDiaryCollectionViewCell"
    
    lazy var diaryCoverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let gradientImageView = UIImageView().then {
        $0.image = UIImage(named: "image_gradientView")
        $0.contentMode = .scaleAspectFill
    }
    
    lazy var titleLabel = UILabel().then {
        let width = self.bounds.width
        $0.preferredMaxLayoutWidth = width - 14
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
        $0.textAlignment = .left
    }

    lazy var dateLabel = UILabel().then {
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        [diaryCoverImageView, gradientImageView, titleLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
        
        diaryCoverImageView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        gradientImageView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-120)
            $0.bottom.equalToSuperview().offset(-40)
            $0.height.equalTo(bounds.height / 3)
        }
        
        dateLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}





    
   
