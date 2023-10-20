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

    private lazy var moveNextButton: UIButton = {
        let button = UIButton()
        button.setUpButton(title: "회원가입", podaFont: .subhead4)
        button.addTarget(self, action: #selector(moveToCompletsButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var test: UIButton = {
        let button = UIButton()
        button.setUpButton(title: "로그인", podaFont: .subhead4)
        button.addTarget(self, action: #selector(loginButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
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
    @objc private func loginButton(){
        
    }

    let authManager = FireAuthManager()
    let firebaseImageManager = FireStorageImageManager()
    
    @objc private func moveToCompletsButtonTapped() {
//        let mainVC = MainViewController(viewModel: MainViewModel())
//        mainVC.bind(to: mainVC.viewModel)
//        navigationController?.pushViewController(mainVC, animated: true)
  
        


//        let imageData = UIImage(named: "image_profile")?.pngData()
//
//        DispatchQueue.main.async{
//            self.firebaseImageManager.createProfileImage(imageData: imageData!){ error in
//                if error == .none{
//                    print("성공")
//                }else{
//                    print("실패")
//                }
//            }
//        }

        
        DispatchQueue.global(qos:.background).async{
            self.authManager.userLogin(email: "gjonegg4@abc.com", password: "gjonegg"){ [weak self] error in
                guard let self = self else {return}

                if error == .none{
                    print("로그인 성공")
                } else{
                    print("로그인 실패")
                }
            }
        }
        
        
//        let imageData = UIImage(named: "image_profile")?.pngData()
//            DispatchQueue.main.async{
//                self.authManager.signUpUser(email: "gjonegg4@abc.com", password: "gjonegg", profileImage: imageData, nickName: "nickname"){ error in
//                if error == .none{
//                    print("유저 계정 생성 성공")
//                }else {
//                    print("유저 계정 생성 실패")
//                }
//            }
//        }
    }
}
