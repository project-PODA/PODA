//
//  PageCollectionViewCell.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PageCollectionViewCell"

    @IBOutlet weak var pageButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "PageCollectionViewCell", bundle: nil)
    }
    
    @IBAction func touchUpPageButton(_ sender: Any) {
        
    }
    
    @IBAction func touchUpDeleteButton(_ sender: Any) {
        
    }
}
