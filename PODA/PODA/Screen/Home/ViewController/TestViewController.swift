//
//  TestViewController.swift
//  PODA
//
//  Created by 랑 on 2023/11/03.
//

import UIKit
import SnapKit
import Then

class TestViewController: UIViewController {
    
    lazy var diaryCoverView = UIImageView().then {
        $0.image = UIImage(systemName: "plus")
        $0.backgroundColor = .red
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 7
        $0.layer.shadowColor = Palette.podaBlack.getColor().cgColor
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        view.addSubview(diaryCoverView)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        diaryCoverView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    @objc func didTapBackButton() {
            self.navigationController?.popViewController(animated: true)
    }
    
}
