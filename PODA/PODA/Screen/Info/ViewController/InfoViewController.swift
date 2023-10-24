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
    
    
    private let items: [String] = ["버전", "개인정보처리방침", "공지사항", "기능 추가 요청/오류 신고", "만든이", "탈퇴하기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    
    func configUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["poda_official@naver.com"])
            //첨부파일 보내려면 코드 추가해야함. 다음 커밋에 올리겠음.
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
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            sendEmail()
        } else if indexPath.row == 1 { // "개인정보처리방침" 셀을 눌렀을 때
            if let url = URL(string: "https://poda-project.notion.site/bf5c40465131409297eb8d5217b0c441?pvs=4") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
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
