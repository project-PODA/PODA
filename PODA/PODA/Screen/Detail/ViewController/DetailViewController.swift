//
//  DetailViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/21.
//

import UIKit

class DetailViewController: BaseViewController, UIConfigurable {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var viewVelocity = CGPoint(x: 0, y: 0)
    var diaryData : DiaryData?
    lazy var backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "image_background2") // 저장된 이미지 불러오기
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let scrollImageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        let image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
    }

    private let scrollLabel = UILabel().then {
        $0.setUpLabel(title: "scroll to open diary", podaFont: .body2)
        $0.textColor = Palette.podaWhite.getColor()
        $0.sizeToFit()  // scrollLabel.bounds.width 알기 위해 필요
        $0.transform = CGAffineTransform(rotationAngle: -.pi / 2)
    }
    
    private let pageCountimageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .ultraLight)
        let image = UIImage(systemName: "square", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
//        gradientLayer.colors = [UIColor(red: 1, green: 0.541, blue: 0.541, alpha: 1).cgColor,
//                                UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        gradientLayer.locations = [0.0 ,1.0]
//        $0.layer.addSublayer(gradientLayer)
        
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
        $0.setUpLabel(title: "석진이랑 인생네컷 모음", podaFont: .display3) // 저장된 title 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.12", podaFont: .head1) // 저장된 날짜 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let contentLabel = UILabel().then {
        $0.setUpLabel(title: "다이어리 내용 어쩌구 저쩌구 여기부턴 한글더미 국민의 모든 자유와 권리는 국가안전보장·질서유지 또는 공공복리를 위하여 필요한 경우에 한하여 어쩌구.", podaFont: .body2) // 저장된 내용 불러오기
        $0.lineBreakMode = .byCharWrapping
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        addSwipeGesture()
        setupComp()
    }
    private func setupComp() {
        backgroundImageView.image = UIImage(data: diaryData!.diaryImageList[0])
        dateLabel.text = diaryData?.createDate
        contentLabel.text = diaryData?.description
    }
    
    func configUI() {
        [backgroundImageView, backButton, scrollLabel, scrollImageView, pageCountimageView, titleLabel, dateLabel, contentLabel].forEach {
            view.addSubview($0)
        }
        
        backgroundImageView.snp.makeConstraints { 
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
        
        pageCountimageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).offset(-16)
            $0.left.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { 
            $0.bottom.equalTo(dateLabel.snp.top)
            $0.left.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { 
            $0.bottom.equalTo(contentLabel.snp.top).offset(-28)
            $0.left.equalToSuperview().offset(20)
        }
        
        contentLabel.snp.makeConstraints { 
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-44)
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
            saveDeleteVC.dateLabel.text = diaryData?.createDate
            saveDeleteVC.diaryName = diaryData?.diaryName
            saveDeleteVC.imageView.image = UIImage(data: diaryData!.diaryImageList[0])
            navigationController?.pushViewController(saveDeleteVC, animated: true)
        }
    }
}

extension UIButton {
    func alignTextBelow(spacing: CGFloat) {
        guard let image = self.imageView?.image,
              let titleLabel = self.titleLabel,
              let titleText = titleLabel.text else { return }
        
        let titleSize = titleText.size(withAttributes: [
            NSAttributedString.Key.font: titleLabel.font as Any
        ])
        
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
    }
}
