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
    
    /*
    // Auto layout, variables, and unit scale are not yet supported
    var view = UIView()
    view.frame = CGRect(x: 0, y: 0, width: 241.15, height: 322.14)
    let layer0 = CAGradientLayer()
    layer0.colors = [
      UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
      UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
    ]
    layer0.locations = [0, 1]
    layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
    layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
    layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
    layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
    layer0.position = view.center
    view.layer.addSublayer(layer0)


    var parent = self.view!
    parent.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: 241.15).isActive = true
    view.heightAnchor.constraint(equalToConstant: 322.14).isActive = true
    view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 493.14).isActive = true
    view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 324.28).isActive = true
    */
    
    private let gradientView = UIView().then {
        let gradientLayer = CAGradientLayer()
        print(gradientLayer.frame)
        let width = (UIScreen.main.bounds.width - 40) * 2 / 3
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: 320)
        gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
                                UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.75)
        gradientLayer.locations = [0.0 ,1.0]
//        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
//        gradientLayer.bounds = $0.bounds.insetBy(dx: -0.5*$0.bounds.size.width, dy: -0.5*$0.bounds.size.height)
//        gradientLayer.position = $0.center
        $0.layer.addSublayer(gradientLayer)
    }
        
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "example")
        $0.contentMode = .scaleAspectFill
    }
        
    private let titleLabel = UILabel().then {
        $0.setUpLabel(title: "나홀로\n인생네컷\n모음", podaFont: .head1)
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
        $0.textAlignment = .left
    }
        
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.21", podaFont: .subhead2)
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
        
        [imageView, gradientView, titleLabel, dateLabel].forEach(addSubview)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}





    
   
