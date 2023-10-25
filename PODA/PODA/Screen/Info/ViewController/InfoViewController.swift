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
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["poda_official@naver.com"])
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "메일을 보내실 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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
            cell.setVersion("1.0.1")
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
        controller.dismiss(animated: true)
    }
}
