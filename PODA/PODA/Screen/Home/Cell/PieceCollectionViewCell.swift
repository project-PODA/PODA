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
    
    let pieceImageView = UIImageView().then {
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
        backgroundColor = Palette.podaBlack.getColor()

        addSubview(pieceImageView)
        
        pieceImageView.snp.makeConstraints { 
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
    
//    func configure(with imageMemory: ImageMemory) {
//        
//        guard let imagePath = imageMemory.imagePath else { return }
//        print("Image Path: \(imagePath)")
//        
//        if let image = UIImage(contentsOfFile: imagePath) {
//            pieceImageView.image = image
//        } else {
//            print("이미지 경로 없음: \(imagePath)")
//        }
//        
//    }
    
        func getPieceImage(with imageMemory: ImageMemory) -> UIImage {
            
        // 이미지 로드 및 설정
        guard let imagePath = imageMemory.imagePath else { return UIImage() }
        print("Image Path: \(imagePath)")
        
        guard let pieceImage = UIImage(contentsOfFile: imagePath) else { return UIImage() }
        return pieceImage
        
//        // 추억 날짜 설정
//        if let memoryDate = imageMemory.memoryDate {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy. MM. dd"
//            dateLabel.text = dateFormatter.string(from: memoryDate)
//        }
    }
}

