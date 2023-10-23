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
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "image_background2") // 저장된 이미지 불러오기
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
//        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
//        let image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfig)
//        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let imageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        let image = UIImage(systemName: "square", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
        
        let pageCountLabel = UILabel()
        pageCountLabel.setUpLabel(title: "05", podaFont: .head1) // 다이어리 페이지 수 가져오기
        pageCountLabel.textColor = Palette.podaWhite.getColor()
        $0.addSubview(pageCountLabel)
        pageCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        
        let pageLabel = UILabel()
        pageLabel.setUpLabel(title: "pages", podaFont: .caption)
        pageLabel.textColor = Palette.podaWhite.getColor()
        $0.addSubview(pageLabel)
        pageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pageCountLabel.snp.bottom).offset(-4)
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.setUpLabel(title: "석진이랑 인생네컷 모음", podaFont: .display1) // 저장된 title 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let dateLabel = UILabel().then {
        $0.setUpLabel(title: "2023.09.12", podaFont: .head1) // 저장된 날짜 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let contentLabel = UILabel().then {
        $0.setUpLabel(title: "다이어리 내용 어쩌구 저쩌구 여기부턴 한글더미 국민의 모든 자유와 권리는 국가안전보장·질서유지 또는 공공복리를 위하여 필요한 경우에 한하여 어쩌구.", podaFont: .body2) // 저장된 날짜 불러오기
        $0.textColor = Palette.podaWhite.getColor()
        $0.numberOfLines = 3
    }
    
    private let scrollImageView = UIImageView().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 32)
        let image = UIImage(systemName: "chevron.up", withConfiguration: imageConfig)
        $0.image = image
        $0.tintColor = Palette.podaWhite.getColor()
    }

    private let scrollLabel = UILabel().then {
        $0.setUpLabel(title: "scroll to open diary", podaFont: .body2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(scrollView)))
    }
    
    func configUI() {
        [backgroundImageView, backButton, imageView, titleLabel, dateLabel, contentLabel, scrollImageView, scrollLabel].forEach(view.addSubview)
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.right.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(dateLabel.snp.top)
            make.left.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentLabel.snp.top).offset(-32)
            make.left.equalToSuperview().offset(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.bottom.equalTo(scrollImageView.snp.top).offset(-40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        scrollImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(scrollLabel.snp.top)
        }
        
        scrollLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func scrollView(_ sender: UIPanGestureRecognizer) {
        viewTranslation = sender.translation(in: view)
        viewVelocity = sender.translation(in: view)
        
        switch sender.state {
        case .changed:
            if abs(viewVelocity.y) > abs(viewVelocity.x) {
                if viewVelocity.y < 0 {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                    })
                }
            }
        case .ended:
            if viewTranslation.y < -500 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.transform = .identity
                })
            } else {
                let saveDeleteViewController = SaveDeleteViewController()
                saveDeleteViewController.modalPresentationStyle = .fullScreen
                saveDeleteViewController.modalTransitionStyle = .coverVertical
                navigationController?.pushViewController(saveDeleteViewController, animated: true)
//                present(editSaveViewController, animated: true)
            }
        default:
            break
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
