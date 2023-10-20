//
//  DetailDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit

class DetailDiaryViewController: BaseViewController, UIConfigurable {

    // MARK: - Properties
    
    private lazy var navigationBar = DiaryNavigationBar(leftButtonTitle: "뒤로", rightButtonTitle: "저장").then {
        $0.leftButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    // MARK: - InitUI
    
    func configUI() {
        setupLayout()
    }
    
    private func setupLayout() {
        [navigationBar].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        
    }
    
    // MARK: - Custom Method

}
