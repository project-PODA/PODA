//
//  NoticeViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/10/24.
//

import UIKit
import SnapKit
import MessageUI
import Then

class NoticeViewController: BaseViewController, UIConfigurable {
    
    private var notices: [NoticeInfo] = []
    
    // 선택된 셀의 인덱스
    private var selectedIndex: IndexPath? = nil
    
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(NoticeCell.self, forCellReuseIdentifier: "noticeCell")
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotices()
    }
    
    private let dbManager = FirestorageDBManager()
    private func getNotices() {
        dbManager.getNotices { [weak self] notices, error in
            guard let self = self else { return }

            if error == .none && !notices.isEmpty {
                self.notices = notices
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func configUI() {
        let navigationBarAppearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .clear
            $0.titleTextAttributes = [.foregroundColor: Palette.podaWhite.getColor()]
            $0.shadowColor = nil
        }
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        let tabBarAppearance = UITabBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .clear
            $0.shadowColor = nil
        }
        
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        
        
        self.navigationItem.title = "공지사항"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor(named: "podaWhite") ?? .white
        ]
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.backgroundColor = .clear
    }
    
    
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(notices.count)
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeCell
        var notice = notices[indexPath.row]
        cell.configure(title: notice.title, date: Date.updateTime(dateTime: notice.date))
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 84
    }
    

}
