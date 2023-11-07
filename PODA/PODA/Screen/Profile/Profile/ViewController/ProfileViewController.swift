//
//  ProfileViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import UIKit
import Then
import NVActivityIndicatorView


class ProfileViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    var viewModel: ProfileViewModel!
    
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 75
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
        $0.image = UIImage(named: "image_profile")
        $0.contentMode = .scaleAspectFill
    }
    
    private let cameraButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_camera"), for: .normal)
        $0.layer.cornerRadius = 22
    }
    
    private let usernameLabel = UILabel().then {
        $0.setUpLabel(title: "포다포다", podaFont: .head1)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let nickNameEditButton = UIButton().then {
        $0.setUpButton(title: "닉네임 편집", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
    }
    
    private let logoutButton = UIButton().then {
        $0.setUpButton(title: "로그아웃", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    private lazy var loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: Palette.podaWhite.getColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setActions()
        loadingIndicator.startAnimating()
        viewModel.getFirebaseData()
    }
    

    
    private func setComponentDisable(_ enabled : Bool){
        cameraButton.isEnabled = enabled
        nickNameEditButton.isEnabled = enabled
        logoutButton.isEnabled = enabled
    }
    
    private func setActions() {
        cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        nickNameEditButton.addTarget(self, action: #selector(didTapNickNameButton), for: .touchUpInside)
    }
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(coder.debugDescription)
    }
    
    func bindViewModel() {
        viewModel.profileImageSetting = { [weak self] imageData in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(data: imageData)
                self.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.profileNickNameSetting = { [weak self] name in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.usernameLabel.text = name
            }
        }
        
        //🔫4
        viewModel.nickNameUpdate = { [weak self] nickname in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.usernameLabel.text = nickname
            }
        }
        
        //🥕3
        viewModel.imageUpdate = {[weak self] in
            
            DispatchQueue.main.async{
                guard let self = self else {return}
                self.loadingIndicator.stopAnimating()
                self.setComponentDisable(true)
            }
        }
    }
    
    func configUI() {
        setupNavigationBar()
        
        
        [profileImageView, cameraButton, usernameLabel, nickNameEditButton, logoutButton, loadingIndicator].forEach { view.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
            $0.width.height.equalTo(150)
        }
        
        loadingIndicator.snp.makeConstraints{
            $0.width.height.equalTo(50)
            $0.center.equalTo(profileImageView)
        }
        
        cameraButton.snp.makeConstraints {
            $0.bottom.right.equalTo(profileImageView).offset(-3)
            $0.width.height.equalTo(35)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(24)
        }
        
        nickNameEditButton.snp.makeConstraints {
            $0.top.equalTo(usernameLabel.snp.bottom).offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(44)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        
        let infoIcon = UIImage(named: "icon_info")?.withRenderingMode(.alwaysTemplate)
        let infoButtonItem = UIBarButtonItem(image: infoIcon, style: .plain, target: self, action: #selector(didTapInfoButton))
        infoButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem = infoButtonItem
    }
    
  
    @objc private func didTapCameraButton() {
        PhotoAccessHelper.requestPhotoLibraryAccess(presenter: self) { (isAuthorized) in
            if isAuthorized {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    //🔫1
    @objc private func didTapNickNameButton() {
        showAlertWithTextField(title: "닉네임 변경", message: "5글자 이하로 입력해주세요.", placeholder: usernameLabel.text!){ [weak self]  text in
            guard let self = self else { return }
            viewModel.updateNickname(nickname: text ?? "")
        }
    }
    
    @objc private func didTapInfoButton() {
        let infoVC = InfoViewController()
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            
            // 이미지 크기 조정
            let resizedImage = viewModel.resizingImage(image: selectedImage)
            
            profileImageView.image = resizedImage
            loadingIndicator.startAnimating()
            setComponentDisable(false)
            
            //🥕1
            viewModel.updateProfileImage(profileImage: resizedImage)
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
