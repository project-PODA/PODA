//
//  ProfileViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import UIKit
import Then

class ProfileViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    var viewModel: ProfileViewModel!
    
    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 105
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
        $0.image = UIImage(named: "image_profile")
    }
    
    private let cameraButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_camera"), for: .normal)
        $0.layer.cornerRadius = 22
    }
    
    private let usernameLabel = UILabel().then {
        $0.setUpLabel(title: "포다포다", podaFont: .head1)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let profileEditButton = UIButton().then {
        $0.setUpButton(title: "프로필 편집", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.backgroundColor = Palette.podaGray5.getColor()
    }
    
    private let logoutButton = UIButton().then {
        $0.setUpButton(title: "로그아웃", podaFont: .button1, cornerRadius: 22)
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setActions()
        bindViewModel()
    }
    
    private func setActions() {
        cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
    }
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(coder.debugDescription)
    }
    
    func bindViewModel() {
        print("ProfileView bindViewModel called")

    }
    
    func configUI() {
        setupNavigationBar()

        
        [profileImageView, cameraButton, usernameLabel, profileEditButton, logoutButton].forEach { view.addSubview($0) }
        
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
            make.width.height.equalTo(210)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(profileImageView).offset(-8)
            make.width.height.equalTo(44)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
        }
        
        profileEditButton.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(16)
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
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
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
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
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
