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
    
    // 샘플 공지사항 데이터
    private let notices: [Notice] = Array(repeating: Notice(title: "어쩌구저쩌구 어쩌구 제목입니다.", date: "2023.09.12", content: "공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다.공지사항 내용입니다."), count: 10)
    
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
        //        tableView.separatorStyle = .none
    }
    
    
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeCell
        let notice = notices[indexPath.row]
        cell.configure(title: notice.title, date: notice.date, content: notice.content, isExpanded: selectedIndex == indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultHeight: CGFloat = 84
        if selectedIndex == indexPath {
            if let cell = tableView.cellForRow(at: indexPath) as? NoticeCell {
                return defaultHeight + cell.contentLabelHeight()
            }
            return 200
        }
        return defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
        }
        tableView.reloadData()
    }
}
