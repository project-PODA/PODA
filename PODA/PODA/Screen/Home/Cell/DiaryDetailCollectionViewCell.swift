//
//  DiaryDetailCollectionViewCell.swift
//  PODA
//
//  Created by 랑 on 2023/10/20.
//

import UIKit
import Then
import SnapKit

class DiaryDetailCollectionViewCell: UICollectionViewCell, UIConfigurable {
    
    static let identifier = "DiaryDetailCollectionViewCell"
    
    // FIXME: - 다이어리 커버 (첫번째 페이지로 설정) 불러오기
    private let gradientImageView = UIImageView().then {
        let gradientLayer = CAGradientLayer()
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3
        let height = ((UIScreen.main.bounds.height * 5 / 7) - 12) / 2
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.colors = [Palette.podaWhite.getColor().withAlphaComponent(0).cgColor,
                                Palette.podaBlack.getColor().withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0 ,1.0]
        $0.layer.addSublayer(gradientLayer)
        $0.image = UIImage(named: "example") // 다이어리 커버
        $0.contentMode = .scaleAspectFill
    }
    
    // FIXME: - 다이어리 제목 불러오기
    private let titleLabel = UILabel().then {
        $0.setUpLabel(title: "나홀로\n인생네컷\n모음", podaFont: .head1) // 다이어리 제목
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
        $0.textAlignment = .left
    }
    
    // FIXME: - 다이어리 생성 날짜 불러오기
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.21", podaFont: .subhead2) // 생성 날짜
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
        
        [gradientImageView, titleLabel, dateLabel].forEach(addSubview)
        
        gradientImageView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { 
            $0.left.equalTo(16)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        dateLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}





    
   