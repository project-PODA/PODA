//
//  MainViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import UIKit
import SnapKit

class MainViewController: BaseViewController,ViewModelBindable,UIConfigurable {
    
    var viewModel: MainViewModel!
    var firebaseAuth = FireAuthManager()
    var firebaseManager = FireStoreDBManager()
    var firebaseStorageManager = FireStorageImageManager()
    private lazy var moveNextButton: UIButton = {
        let button = UIButton()
        button.setUpButton(title: "이동", podaFont: .subhead4)
        button.addTarget(self, action: #selector(moveToCompletsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        firebaseAuth.userLogin()
    }
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(coder.debugDescription)
    }
    
    func bindViewModel() {
        print("Main bindViewModel called")
    }
    
    func configUI() {
        [moveNextButton].forEach(view.addSubview)
        moveNextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.height.equalTo(50)
        }
    }
    
    @objc private func moveToCompletsButtonTapped() {
    }
}
