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
    
    var gradientHeight: CGFloat = 0
    var gradientWidth: CGFloat = 0
    
    lazy var gradientImageView = UIImageView().then {
        let gradientLayer = CAGradientLayer()
        
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3  // 기기에 따라서 가변적으로 정하고 싶으면 UIScreen 이용
        let height = ((UIScreen.main.bounds.height * 4 / 5) - 12) / 2
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        gradientLayer.colors = [Palette.podaWhite.getColor().withAlphaComponent(0).cgColor,
                                Palette.podaBlack.getColor().withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0 ,1.0]
        $0.layer.addSublayer(gradientLayer)
        $0.contentMode = .scaleAspectFill
    }
    
    private let gradientLayer = CAGradientLayer().then {
        $0.colors = [Palette.podaWhite.getColor().withAlphaComponent(0).cgColor,
                                Palette.podaBlack.getColor().withAlphaComponent(1).cgColor]
        $0.startPoint = CGPoint(x: 0.5, y: 0.25)
        $0.endPoint = CGPoint(x: 0.5, y: 1.0)
        $0.locations = [0.0 ,1.0]
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
        // print("init \(totalHeight), \(safeAreaTop), \(safeAreaBottom)")  // cell 사용할 때에는 init 에서 쓴다기보다는 앞의 VC delegate에서 쓰는 식으로.. cell 재사용 되니카
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        [gradientImageView, titleLabel, dateLabel].forEach {
            contentView.addSubview($0)
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
    
    func updateGradientLayer() {
        print("\(gradientWidth), \(gradientHeight)")
        let width = gradientWidth
        let height = gradientHeight // ((view.frame - 12) / 2  // cell은 view.frame이 아니라 contentView.frame or self.frame or 그냥 frame
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.colors = [Palette.podaWhite.getColor().withAlphaComponent(0).cgColor,
                                Palette.podaBlack.getColor().withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0 ,1.0]
        //gradientImageView.layer.addSublayer(gradientLayer)
        layer.addSublayer(gradientLayer)
        print("updateGradientLayer 실행")
    }
}





    
   
