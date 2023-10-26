//
//  CustomLoadingIndicator.swift
//  PODA
//
//  Created by FUTURE on 2023/10/26.
//

import UIKit
import NVActivityIndicatorView
import Then
import SnapKit

class CustomLoadingIndicator: UIView {
    
    private lazy var loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: Palette.podaWhite.getColor()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    
    private let backgroundView = UIView().then {
           $0.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.5)
           $0.layer.cornerRadius = 8
           $0.isHidden = true
       }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
           addSubview(backgroundView)
           addSubview(loadingIndicator)

           backgroundView.snp.makeConstraints { make in
               make.center.equalToSuperview()
               make.width.height.equalTo(100)
           }

           loadingIndicator.snp.makeConstraints { make in
               make.center.equalToSuperview()
               make.width.height.equalTo(52)
           }
       }
       
       func startAnimating() {
           loadingIndicator.startAnimating()
           backgroundView.isHidden = false
       }
       
       func stopAnimating() {
           loadingIndicator.stopAnimating()
           backgroundView.isHidden = true
       }
   }
