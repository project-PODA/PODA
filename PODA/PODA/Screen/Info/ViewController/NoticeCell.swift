//
//  NoticeTableViewCell.swift
//  PODA
//
//  Created by FUTURE on 2023/10/24.
//

import UIKit
import SnapKit
import MessageUI
import Then

class NoticeCell: UITableViewCell {
    
    private var isExpanded: Bool = false
    
    private let titleLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.font = .podaFont(.body2)
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = Palette.podaGray3.getColor()
        $0.font = .podaFont(.body2)
    }
    
//    private let contentLabel = UILabel().then {
//        $0.textColor = Palette.podaWhite.getColor()
//        $0.font = .podaFont(.body2)
//        $0.layer.backgroundColor = Palette.podaGray5.getColor().cgColor
//        $0.numberOfLines = 0
//    }
    
    //    private let disclosureImageView = UIImageView(image: UIImage(named: "icon_disclosure")).then {
    //        $0.contentMode = .scaleAspectFit
    //        $0.tintColor = Palette.podaWhite.getColor()
    //    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(titleLabel)
        addSubview(dateLabel)
//        addSubview(contentLabel)
        
        //        addSubview(disclosureImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(15)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
        }
        
//        contentLabel.snp.makeConstraints { make in
//            make.top.equalTo(dateLabel.snp.bottom).offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-10)
//        }
        
//        contentLabel.isHidden = true  // 기본적으로 숨깁니다.
        
        //
        //        disclosureImageView.snp.makeConstraints { make in
        //            make.centerY.equalToSuperview()
        //            make.trailing.equalToSuperview().offset(-15)
        //            make.size.equalTo(CGSize(width: 6, height: 11))
        //        }
    }
    
    func configure(title: String, date: String) {
        titleLabel.text = "[공지] \(title)"
        dateLabel.text = date
//        contentLabel.text = content

//        self.isExpanded = isExpanded
//        contentLabel.isHidden = !isExpanded
    }

//    func contentLabelHeight() -> CGFloat {
//        let width = contentView.frame.width
//        let size = contentLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
//        return size.height
//    }
}
