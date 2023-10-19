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
    
    let diaryView = UIView().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.layer.cornerRadius = 5
        let titleLabel = UILabel()
        titleLabel.text = "나홀로\n인생네컷\n모음"
        titleLabel.textColor = Palette.podaWhite.getColor()
        titleLabel.font = UIFont.podaFont(.subhead3)
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .left
        $0.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.bottom.equalToSuperview().offset(-6)
        }
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_bookMark")
        imageView.contentMode = .scaleAspectFill
        $0.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
        }
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
        
        addSubview(diaryView)
        
        diaryView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}
