//
//  InfoViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/22.
//

import UIKit
import SnapKit
import MessageUI
import Then


class InfoViewController: BaseViewController, UIConfigurable, ViewModelBindable {
    
    
    var viewModel: InfoViewModel!
    
    init(viewModel: InfoViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(InfoCell.self, forCellReuseIdentifier: "infoCell")
        $0.backgroundColor = .clear
    }
    
    private lazy var logoutButton = UIButton().then {
        $0.setUpButton(title: "로그아웃", podaFont: .caption)
        $0.setTitleColor(Palette.podaGray3.getColor(), for: .normal)
        $0.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    private lazy var leaveButton = UIButton().then {
        $0.setUpButton(title: "회원탈퇴", podaFont: .caption)
        $0.setTitleColor(Palette.podaGray3.getColor(), for: .normal)
        $0.addTarget(self, action: #selector(didTapLeaveButton), for: .touchUpInside)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let baseTabbar = self.tabBarController as? BaseTabbarController {
            baseTabbar.setCustomTabbarHidden(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let baseTabbar = self.tabBarController as? BaseTabbarController {
            baseTabbar.setCustomTabbarHidden(false)
        }
    }
    
    func bindViewModel() {
        
    }
    
    
    func configUI() {
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        [tableView, logoutButton, leaveButton].forEach {
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        logoutButton.snp.makeConstraints {
            $0.right.equalTo(leaveButton.snp.left).offset(-16)
            $0.bottom.equalTo(tableView.snp.bottom).offset(10)
        }
        
        leaveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(logoutButton)
        }
    }
    
    
    func setTableView() {
        tableView.setUpTableView(delegate: self, dataSource: self, cellType: InfoCell.self)
        tableView.isScrollEnabled = false
    }
    
    func didTapEmailSupportButton() {
        viewModel.sendEmail { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let mailComposeVC):
                    mailComposeVC.mailComposeDelegate = self
                    self?.present(mailComposeVC, animated: true, completion: nil)
                case .failure(let error):
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    
    private func showErrorAlert(error: Error) {
        let message = (error as NSError).domain == "MailServicesError" ? "이메일 설정을 확인하고 다시 시도해주세요.\n('설정'앱>Mail>계정>계정추가)\n\n문의 : poda_official@naver.com" : "앱 버전 정보를 가져올 수 없습니다."
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        present(alertController, animated: true)
    }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func didTapLogoutButton() {
        
        let alertController = UIAlertController(title: nil, message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.viewModel.logout(completion: {
                self?.moveToHome()
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapLeaveButton() {
        let viewModel = LeaveViewModel(fireAuthManager: FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator())))
        let leaveViewController = LeaveViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(leaveViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoCell
        
        if indexPath.row == 0 {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.setVersion(version)
            }
        } else {
            let itemTitle = viewModel.getItemTitle(indexPath.row)
            cell.setTitle(itemTitle)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // 버전
            break
        case 1: // 개인정보처리방침
            if let url = URL(string: "https://poda-project.notion.site/7f58cdb40f3348b8b486960f255b051e?pvs=4") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2: // 서비스 이용 약관
            if let url = URL(string: "https://poda-project.notion.site/f6e3b59ad589488c8079f184d11136a4?pvs=4") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 3: // 공지사항
            let noticeVC = NoticeViewController()
            self.navigationController?.pushViewController(noticeVC, animated: true)
        case 4: // 기능 추가 요청/오류 신고
            didTapEmailSupportButton()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - MFMailComposeViewControllerDelegate
extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("cancelled")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        @unknown default:
            print("error")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIDevice Extension.
extension UIDevice {
    // iOS Version
    static let iOSVersion = "\(current.systemName) \(current.systemVersion)"
    
    // iPhone Model
    private static var hardwareString: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return model
    }
    
    private static var modelDictionary: [String: String] {
        return [
            "i386": "Simulator",   // 32 bit
            "x86_64": "Simulator", // 64 bit
            "iPhone8,1": "iPhone 6S",
            "iPhone8,2": "iPhone 6S Plus",
            "iPhone8,4": "iPhone SE 1st generation",
            "iPhone9,1": "iPhone 7",
            "iPhone9,3": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,4": "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE 2nd generation",
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 Mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE 3nd generation",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max"
        ]
    }
    
    static var iPhoneModel: String {
        return modelDictionary[hardwareString] ?? "Unknown iPhone - \(hardwareString)"
    }
}
