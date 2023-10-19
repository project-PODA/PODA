//
//  HomeMenuViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/17.
//

import UIKit
import Then
import SnapKit

class HomeMenuViewController: BaseViewController, UIConfigurable {
    
    private let qrButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_qr"), for: .normal)
        $0.addTarget(self, action: #selector(didTapQrButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let qrLabel = UILabel().then {
        $0.text = "QR코드 촬영"
        $0.font = UIFont.podaFont(.subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let addDiaryButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_diary"), for: .normal)
        $0.addTarget(self, action: #selector(didTapAddDiaryButton), for: .touchUpInside)
    }
    
    private let addDiaryLabel = UILabel().then {
        $0.text = "추억 다이어리 만들기"
        $0.font = UIFont.podaFont(.subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let addPieceButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_piece"), for: .normal)
        $0.addTarget(self, action: #selector(didTapAddPieceButton), for: .touchUpInside)
    }
    
    private let addPieceLabel = UILabel().then {
        $0.text = "추억 조각 등록하기"
        $0.font = UIFont.podaFont(.subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.layer.cornerRadius = 28
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        view.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.8)
        
        let qrStackView = UIStackView(arrangedSubviews: [qrButton, qrLabel])
        qrStackView.axis = .vertical
        qrStackView.alignment = .center
        qrStackView.spacing = 8
        
        let addDiaryStackView = UIStackView(arrangedSubviews: [addDiaryButton, addDiaryLabel])
        addDiaryStackView.axis = .vertical
        addDiaryStackView.alignment = .center
        addDiaryStackView.spacing = 8
        
        let addPieceStackView = UIStackView(arrangedSubviews: [addPieceButton, addPieceLabel])
        addPieceStackView.axis = .vertical
        addPieceStackView.alignment = .center
        addPieceStackView.spacing = 8
        
        let buttonStackView = UIStackView(arrangedSubviews: [qrStackView, addDiaryStackView, addPieceStackView, closeButton])
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .center
        buttonStackView.spacing = 24
        
        view.addSubview(buttonStackView)
        
        qrButton.snp.makeConstraints { make in
            make.width.height.equalTo(96)
        }
        
        addDiaryButton.snp.makeConstraints { make in
            make.width.height.equalTo(96)
        }
        
        addPieceButton.snp.makeConstraints { make in
            make.width.height.equalTo(96)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc func didTapAddDiaryButton() {
        // 추억 다이어리 만들기 페이지로 이동
    }
    
    @objc func didTapAddPieceButton() {
        // 추억 조각 등록하기 페이지로 이동
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }
}

extension HomeMenuViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @objc func didTapQrButton() {
        // 카메라 On
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        self.present(camera, animated: true)
    }
}
