//
//  ColorCollectionViewCell.swift
//  PODA
//
//  Created by 배은서 on 2023/10/20.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ColorCollectionViewCell"

    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func nib() -> UINib {
        return UINib(nibName: "ColorCollectionViewCell", bundle: nil)
    }
    
    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }
}
