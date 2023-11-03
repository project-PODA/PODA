//
//  NoticeViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/24.
//

// MARK: - Import Statements
import UIKit
import SnapKit
import Then

class NoticeCell: UITableViewCell {

    // MARK: - Properties
    private var isExpanded: Bool = false

    private let titleLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.font = .podaFont(.body2)
    }

    private let dateLabel = UILabel().then {
        $0.textColor = Palette.podaGray3.getColor()
        $0.font = .podaFont(.body2)
    }

    private let contentBox = UIView().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
    }

    private let contentLabel = UILabel().then {
        $0.font = .podaFont(.body2)
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 0
    }
    
    private let chevronImageView = UIImageView().then {
        $0.tintColor = Palette.podaWhite.getColor()
    }

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configUI
    private func configUI() {
        // Adding subviews
        [titleLabel, dateLabel, contentBox, chevronImageView].forEach {
            contentView.addSubview($0)
        }
        contentBox.addSubview(contentLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(titleLabel)
            $0.height.equalTo(20)
        }

        contentBox.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(0)
            $0.bottom.equalToSuperview().offset(-10)
        }

        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }

        contentBox.isHidden = true
    }

    // MARK: - funcs
    func configure(title: String, date: String, content: String, isContentVisible: Bool) {
        titleLabel.text = title
        dateLabel.text = date
        contentLabel.text = content

        contentBox.isHidden = !isContentVisible
        contentLabel.isHidden = !isContentVisible
        
        let chevronImageName = isContentVisible ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: chevronImageName)
    }
}
