//
//  BaseTabbarController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit
import SnapKit

class BaseTabbarController: UITabBarController {
    
    private let customTabbarView = UIView()
    private let qrContainerView = UIView()
    private let homeContainerView = UIView()
    private let profileContainerView = UIView()
    private let qrImageView = UIImageView()
    private let homeImageView = UIImageView()
    private let profileImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qrViewController = QRViewController()
        qrViewController.backButton.isHidden = true
        
        let homeViewModel = HomeViewModel(firebaseDBManager: FirestorageDBManager(), firebaseImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        homeViewController.bind(to: homeViewController.viewModel)
        
//        let viewModel = ProfileViewModel(fireDBManager: FirestorageDBManager(), fireImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
//        let profileViewController = ProfileViewController(viewModel: viewModel)
//        let profileNavVC = BaseNavigationController(rootViewController: profileViewController)
//        profileViewController.bind(to: profileViewController.viewModel)
        
        let fireAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
        let infoViewController = InfoViewController(viewModel: InfoViewModel(fireAuthManager: fireAuthManager))
        let infoNavViewController = BaseNavigationController(rootViewController: infoViewController)
        
        let mapViewController = MapViewController()
        
        //viewControllers = [qrViewController, homeViewController, infoNavViewController]
        viewControllers = [qrViewController, homeViewController, mapViewController]
        
        // HomeViewController를 초기 실행될 앱으로 지정
        selectedIndex = 1
        
        setupCustomTabbar()
        updateTabbarImages()
    }
    
    private func updateTabbarImages() {
        switch self.selectedIndex {
        case 0: // QR
            qrImageView.image = UIImage(named: "icon_qrCode.selected")
            homeImageView.image = UIImage(named: "icon_home")
            profileImageView.image = UIImage(named: "icon_person")
        case 1: // 홈
            qrImageView.image = UIImage(named: "icon_qrCode")
            homeImageView.image = UIImage(named: "icon_home.selected")
            profileImageView.image = UIImage(named: "icon_person")
        case 2: // 마이페이지
            qrImageView.image = UIImage(named: "icon_qrCode")
            homeImageView.image = UIImage(named: "icon_home")
            profileImageView.image = UIImage(named: "icon_person.selected")
        default:
            break
        }
    }
    
    private func setupCustomTabbar() {
        tabBar.isHidden = true
        customTabbarView.backgroundColor = Palette.podaGray5.getColor().withAlphaComponent(1.0)
        customTabbarView.layer.cornerRadius = 40
        view.addSubview(customTabbarView)
        
        [qrContainerView, homeContainerView, profileContainerView].forEach {
            $0.layer.cornerRadius = 35
            $0.isUserInteractionEnabled = true
            customTabbarView.addSubview($0)
        }
        
        qrContainerView.addSubview(qrImageView)
        homeContainerView.addSubview(homeImageView)
        profileContainerView.addSubview(profileImageView)
        
        customTabbarView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalTo(280)
            $0.bottom.equalTo(view.snp.bottom).offset(-20)
            $0.centerX.equalToSuperview()
        }
        
        qrContainerView.snp.makeConstraints {
            $0.height.width.equalTo(60)
            $0.left.equalTo(customTabbarView.snp.left).offset(7.5)
            $0.centerY.equalToSuperview()
        }
        
        homeContainerView.snp.makeConstraints {
            $0.height.width.equalTo(60)
            $0.center.equalToSuperview()
        }
        
        profileContainerView.snp.makeConstraints {
            $0.height.width.equalTo(60)
            $0.right.equalTo(customTabbarView.snp.right).offset(-7.5)
            $0.centerY.equalToSuperview()
        }
        
        qrImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        homeImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        profileImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        let qrTapGesture = UITapGestureRecognizer(target: self, action: #selector(qrTapped))
        qrContainerView.addGestureRecognizer(qrTapGesture)
        
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeTapped))
        homeContainerView.addGestureRecognizer(homeTapGesture)
        
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileContainerView.addGestureRecognizer(profileTapGesture)
    }
    
    func setCustomTabbarHidden(_ hidden: Bool, animated: Bool = true) {
        if animated {
            UIView.transition(with: customTabbarView, duration: 0.3, options: .transitionCrossDissolve) {
                self.customTabbarView.isHidden = hidden
            }
        } else {
            customTabbarView.isHidden = hidden
        }
    }
    
    @objc private func qrTapped() {
        self.selectedIndex = 0
        updateTabbarImages()
    }
    
    @objc private func homeTapped() {
        self.selectedIndex = 1
        updateTabbarImages()
    }
    
    @objc private func profileTapped() {
        self.selectedIndex = 2
        updateTabbarImages()
    }
}
