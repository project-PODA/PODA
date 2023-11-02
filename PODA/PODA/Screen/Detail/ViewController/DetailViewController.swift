//
//  DetailViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/21.
//

import UIKit

class DetailViewController: BaseViewController, UIConfigurable {
    
    var diaryData : DiaryData?
    
    // FIXME: - 1. 블러? 그라데이션? 2. 가능하다면 : 표지의 속지 배경색을 그라데이션 색상으로, 불가능하다면 : 검정색으로 그라데이션
    lazy var diaryCoverView = UIImageView().then {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        gradientLayer.colors = [Palette.podaWhite.getColor().withAlphaComponent(0).cgColor,
                                Palette.podaBlack.getColor().withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0 ,1.0]
        $0.layer.addSublayer(gradientLayer)
        $0.contentMode = .scaleAspectFill
        
//        let blurEffectView = UIVisualEffectView().then {
//            $0.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
//        }
//        $0.addSubview(blurEffectView)
//        
//        blurEffectView.snp.makeConstraints {
//            $0.top.bottom.left.right.equalToSuperview()
//        }
    }

    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 7
        $0.layer.shadowColor = Palette.podaBlack.getColor().cgColor
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    
    }
    
    private let scrollImageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        let image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addShadowToImageView()
    }

    private let scrollLabel = UILabel().then {
        $0.setUpLabel(title: "scroll to open diary", podaFont: .body2)
        $0.textColor = Palette.podaWhite.getColor()
        $0.addShadowToLabel()
        $0.sizeToFit()  // scrollLabel.bounds.width 알기 위해 필요
        $0.transform = CGAffineTransform(rotationAngle: -.pi / 2)
    }
    
    // FIXME: - 다이어리 페이지 추가 기능 구현하고 나면 다이어리 페이지 수 가져와야 함
    private let pageCountimageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .ultraLight)
        let image = UIImage(systemName: "square", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addShadowToImageView()
        
        let pageCountLabel = UILabel()
        pageCountLabel.setUpLabel(title: "1", podaFont: .display2) // 다이어리 페이지 수 가져오기
        pageCountLabel.textColor = Palette.podaWhite.getColor()
        $0.addSubview(pageCountLabel)
        pageCountLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }
        
        let pageLabel = UILabel()
        pageLabel.setUpLabel(title: "pages", podaFont: .caption)
        pageLabel.textColor = Palette.podaWhite.getColor()
        $0.addSubview(pageLabel)
        pageLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.top.equalTo(pageCountLabel.snp.bottom).offset(-4)
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.addShadowToLabel()
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.addShadowToLabel()
    }
    
    private let contentLabel = UILabel().then {
        $0.lineBreakMode = .byCharWrapping
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 4
        $0.addShadowToLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        addSwipeGesture()
        setupComp()
    }
    
    private func setupComp() {
        guard let diaryData = diaryData else { return }
        diaryCoverView.image = UIImage(data: diaryData.diaryImageList[0])
        titleLabel.setUpLabel(title: diaryData.diaryName, podaFont: .display3)
        dateLabel.setUpLabel(title: Date.updateTime(dateTime: diaryData.createDate), podaFont: .head1)
        contentLabel.setUpLabel(title: diaryData.description, podaFont: .body2)
    }
    
    // FIXME: - 다이어리 페이지 추가 기능 구현하고 나면 pageCountimageView 추가하기
    func configUI() {
        [diaryCoverView, backButton, scrollLabel, scrollImageView, titleLabel, dateLabel, contentLabel].forEach {
            view.addSubview($0)
        }
        
        diaryCoverView.snp.makeConstraints { 
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        scrollLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20 + (scrollLabel.bounds.width / 2) - (scrollLabel.bounds.height / 2))
        }
        
        scrollImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(scrollLabel.snp.left).offset((scrollLabel.bounds.width / 2) - (scrollLabel.bounds.height / 2))
        }
        
//        pageCountimageView.snp.makeConstraints {
//            $0.bottom.equalTo(titleLabel.snp.top).offset(-16)
//            $0.left.equalToSuperview().offset(20)
//        }
        
        titleLabel.snp.makeConstraints { 
            $0.bottom.equalTo(dateLabel.snp.top)
            $0.left.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { 
            $0.bottom.equalTo(contentLabel.snp.top).offset(-28)
            $0.left.equalToSuperview().offset(20)
        }
        
        contentLabel.snp.makeConstraints { 
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-52)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(scrollView))
        swipeGestureRecognizer.direction = .left
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func scrollView(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            let saveDeleteVC = SaveDeleteViewController()
            saveDeleteVC.diaryData = diaryData
            saveDeleteVC.dateLabel.setUpLabel(title: Date.updateTime(dateTime: diaryData?.createDate ?? ""), podaFont: .body1)
            saveDeleteVC.imageView.image = UIImage(data: diaryData?.diaryImageList[0] ?? Data())
            saveDeleteVC.isDiaryImage = true
            saveDeleteVC.editButton.isHidden = true
            navigationController?.pushViewController(saveDeleteVC, animated: true)
        }
    }
}

// FIXME: - extension 파일 추가?
extension UIImageView {
    func addShadowToImageView() {
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 7
        self.layer.shadowColor = Palette.podaBlack.getColor().cgColor
    }
}
