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
    private let fireImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    private let fireDBManager = FirestorageDBManager()
    private let fireAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 105
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
        bindViewModel()
        getFirebaseData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    
    private func getFirebaseData(){
        loadingIndicator.startAnimating()
        fireImageManager.getProfileImage { [weak self] (error, image) in
            guard let self = self else { return }

            if error == .none, let imageData = image {
                DispatchQueue.main.async{ [weak self] in
                    guard let self = self else {return}
                    profileImageView.image = UIImage(data: imageData)
                    loadingIndicator.stopAnimating()
                }
            }
        }
        fireDBManager.getUserNickname{[weak self] (name, error) in
            guard let self = self else {return}
            if error == .none {
                DispatchQueue.main.async{ [weak self] in
                    guard let self = self else {return}
                    usernameLabel.text = name
                }
            }
        }
    }
    
    private func setComponentDisable(_ enabled : Bool){
        cameraButton.isEnabled = enabled
        nickNameEditButton.isEnabled = enabled
        logoutButton.isEnabled = enabled
    }
    
    
    private func setActions() {
        cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        nickNameEditButton.addTarget(self, action: #selector(didnickNameButton), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didLogoutButton), for: .touchUpInside)
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

        
        [profileImageView, cameraButton, usernameLabel, nickNameEditButton, logoutButton, loadingIndicator].forEach { view.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
            $0.width.height.equalTo(210)
        }
        
        loadingIndicator.snp.makeConstraints{
            $0.width.height.equalTo(50)
            $0.center.equalTo(profileImageView)
        }
        
        cameraButton.snp.makeConstraints {
            $0.bottom.right.equalTo(profileImageView).offset(-8)
            $0.width.height.equalTo(44)
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
        
        logoutButton.snp.makeConstraints { 
            $0.height.equalTo(44)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
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
    
    @objc private func didnickNameButton() {
        showAlertWithTextField(title: "닉네임 변경", message: "5글자 이하로 입력해주세요.", placeholder: usernameLabel.text!){ [weak self]  text in
            guard let self = self else {return}
            if let nickname = text {
                usernameLabel.text = nickname
                updateNickname(nickname: nickname)
            }
        }
    }
    private func updateNickname(nickname newNickname: String) {
        fireDBManager.updateNickname(updateName: newNickname) { [weak self]  error in
            guard let _ = self else { return }
            print("Update 성공")
        }
    }
    
    @objc private func didLogoutButton() {
        let alertController = UIAlertController(title: nil, message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.fireAuthManager.userLogOut() { error in
                if error == .none {
                    UserDefaultManager.isUserLoggedIn = false
                    UserDefaultManager.userEmail = ""
                    UserDefaultManager.userPassword = ""
                    self.moveToHome()
                    
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        present(alertController, animated: true, completion: nil)
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
            let newSize = CGSize(width: 300, height: 300 * selectedImage.size.height / selectedImage.size.width)
            let resizedImage = selectedImage.resized(to: newSize)
            
            profileImageView.image = resizedImage
            loadingIndicator.startAnimating()
            setComponentDisable(false)
            
            fireImageManager.createProfileImage(imageData: resizedImage!.pngData()!) { [weak self] (error) in
                guard let self = self else { return }
                DispatchQueue.main.async{ [weak self]  in
                    if error == .none {
                        guard let self = self else {return}
                        loadingIndicator.stopAnimating()
                        setComponentDisable(true)
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
