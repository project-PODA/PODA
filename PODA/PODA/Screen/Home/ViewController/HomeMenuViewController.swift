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
    
    var touchedDiary: (() -> Void)?
    var touchedPiece: (() -> Void)?
    
    private let qrButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_qr"), for: .normal)
        $0.addTarget(self, action: #selector(didTapQrButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
    private let qrLabel = UILabel().then {
        $0.setUpLabel(title: "QR코드 촬영", podaFont: .subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let addDiaryButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_diary"), for: .normal)
        $0.addTarget(self, action: #selector(didTapAddDiaryButton), for: .touchUpInside)
    }
    
    private let addDiaryLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리 만들기", podaFont: .subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let addPieceButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_piece"), for: .normal)
        $0.addTarget(self, action: #selector(didTapAddPieceButton), for: .touchUpInside)
    }
    
    private let addPieceLabel = UILabel().then {
        $0.setUpLabel(title: "추억 조각 등록하기", podaFont: .subhead2)
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
        
        qrButton.snp.makeConstraints { 
            $0.width.height.equalTo(96)
        }
        
        addDiaryButton.snp.makeConstraints { 
            $0.width.height.equalTo(96)
        }
        
        addPieceButton.snp.makeConstraints { 
            $0.width.height.equalTo(96)
        }
        
        closeButton.snp.makeConstraints { 
            $0.width.height.equalTo(56)
        }
        
        buttonStackView.snp.makeConstraints { 
            $0.center.equalToSuperview()
        }
    }
    
    @objc func didTapAddDiaryButton() {
        guard let touchedDiary else { return }
        touchedDiary()
    }
    
    @objc func didTapAddPieceButton() {
        guard let touchedPiece else { return }
        touchedPiece()
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }
}

extension HomeMenuViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // FIXME: - 카메라 권한 설정
    @objc func didTapQrButton() {
        // 카메라 On
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        present(camera, animated: true)
    }
}
