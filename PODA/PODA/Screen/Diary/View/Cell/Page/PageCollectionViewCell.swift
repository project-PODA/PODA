//
//  PageCollectionViewCell.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PageCollectionViewCell"

    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageImageView.layer.cornerRadius = 5
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "PageCollectionViewCell", bundle: nil)
    }
    
    @IBAction func touchUpDeleteButton(_ sender: Any) {
        
    }
    
    func setPageImage(_ image: UIImage) {
        pageImageView.layer.cornerRadius = 5
        pageImageView.clipsToBounds = true
        pageImageView.image = image
    }
}
