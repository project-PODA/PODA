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
        //        let mainVC = MainViewController(viewModel: MainViewModel())
        //        mainVC.bind(to: mainVC.viewModel)
        //        navigationController?.pushViewController(mainVC, animated: true)
        
        //밑에는 테스트코드. 머지시 삭제예정
        let image1 = UIImage(named: "logo_poda")
        let image2 = UIImage(named: "logo_poda")
        let imageList = [image1!.pngData()!, image2!.pngData()!]
        let pageDataList = [
            PageInfo(
                page: 1,
                backgroundColor: "#AA00EE",
                componentInfo: ComponentInfo(
                    image: [],
                    sticker: [],
                    label: []
                )
            ),
            PageInfo(
                page: 2,
                backgroundColor: "#EEAA33",
                componentInfo: ComponentInfo(
                    image: [],
                    sticker: [],
                    label: []
                )
            )
        ]

        let title = "제목4"
        
        firebaseManager.createDiary(deviceName: UIDevice.current.name,pageDataList : pageDataList,title: title, description: "내용임2", frameRate: .OneToOne, backgroundColor: "#FF00FF"){ [weak self] error in
            guard let self = self else{return}
            if error == nil {
                firebaseStorageManager.createDiaryImage(diaryTitle: title, pageImageList: imageList){ error in
                }
            }else{
                print("error -> \(error?.localizedDescription)")
            }
        }
    }
}
