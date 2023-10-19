//
//  DiaryViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/18.
//

import UIKit
import Then
import SnapKit

class HomeDiaryViewController: BaseViewController, UIConfigurable {
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)    // warning - lazy var 로 해결?
    }
    
//    private let diaryCollectionView = UICollectionView().then {
//        
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    func configUI() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
    }
    
    @objc func didTapBackButton() {
        dismiss(animated: true)
    }

}
