//
//  StickerCollectionViewCell.swift
//  PODA
//
//  Created by 배은서 on 2023/10/22.
//

import UIKit
import SnapKit

class StickerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "StickerCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "StickerCollectionViewCell", bundle: nil)
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }

}
