//
//  FontCollectionViewCell.swift
//  PODA
//
//  Created by 배은서 on 2023/10/23.
//

import UIKit

class FontCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FontCollectionViewCell"

    @IBOutlet weak var fontLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fontLabel.textColor = Palette.podaWhite.getColor()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "FontCollectionViewCell", bundle: nil)
    }
    
    func setFontLabel(_ font: Font) {
        fontLabel.textColor = Palette.podaWhite.getColor()
        fontLabel.text = font.text
        fontLabel.font = font.font
    }

}
