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

class InfoViewController: BaseViewController, UIConfigurable {
    
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(InfoCell.self, forCellReuseIdentifier: "infoCell")
        $0.backgroundColor = .clear
    }
    
    
    private let items: [String] = ["버전", "개인정보처리방침", "공지사항", "기능 추가 요청/오류 신고", "탈퇴하기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setTableView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func configUI() {
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    func setTableView() {
        tableView.setUpTableView(delegate: self, dataSource: self, cellType: InfoCell.self)
    }
    
    func sendEmail() {
        // App Version.
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }

        // mail 을 연동해서 보낼 수 있는가를 체크.
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(["poda_official@naver.com"])
            mailComposeVC.setSubject("PODA 문의 사항")
            mailComposeVC.setMessageBody("문의 사항을 상세히 입력해주세요. \n\n App Version: \(appVersion) \n Device: \(UIDevice.iPhoneModel) \n OS: \(UIDevice.iOSVersion)", isHTML: false)
            mailComposeVC.modalPresentationStyle = .overFullScreen
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            // mail 이 계정과 연동되지 않은 경우.
            let mailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in }
            mailErrorAlert.addAction(confirmAction)
            present(mailErrorAlert, animated: true, completion: nil)
        }
    }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoCell
        
        if indexPath.row == 0 {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.setVersion(version)
            }
        } else {
            cell.setTitle(items[indexPath.row])
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
            if let url = URL(string: "https://poda-project.notion.site/bf5c40465131409297eb8d5217b0c441?pvs=4") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2: // 공지사항
            let noticeVC = NoticeViewController()
            self.navigationController?.pushViewController(noticeVC, animated: true)
        case 3: // 기능 추가 요청/오류 신고
            sendEmail()
        case 4: // 탈퇴하기
            let leaveVC = LeaveViewController()
            self.navigationController?.pushViewController(leaveVC, animated: true)
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
// 🔥 iOS Version
    static let iOSVersion = "\(current.systemName) \(current.systemVersion)"

// 🔥 iPhone Model
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

    /// Referenced the following URL.
    /// [List of iOS and iPadOS devices](https://en.wikipedia.org/wiki/List_of_iOS_and_iPadOS_devices)
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
            "iPhone14,6": "iPhone SE 3nd generation"
        ]
    }

    static var iPhoneModel: String {
        return modelDictionary[hardwareString] ?? "Unknown iPhone - \(hardwareString)"
    }
}
