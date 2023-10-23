//
//  InfoCell.swift
//  PODA
//
//  Created by FUTURE on 2023/10/23.
//

import UIKit
import SnapKit

class InfoCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.podaFont(.body2)
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.podaFont(.body2)
        return label
    }()
    
    
    private let disclosureIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_disclosure"))
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(disclosureIcon)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalTo(disclosureIcon.snp.leading).offset(0)
            make.centerY.equalToSuperview()
        }
        
        disclosureIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setVersion(_ version: String) {
        titleLabel.text = "버전"
        detailLabel.text = version
        detailLabel.textColor = Palette.podaBlue.getColor()
        disclosureIcon.isHidden = true
    }
    
}

