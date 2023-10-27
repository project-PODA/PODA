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
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(NoticeCell.self, forCellReuseIdentifier: "noticeCell")
        $0.backgroundColor = .clear
    }
    
    private let dbManager = FirestorageDBManager()
    
    // MARK: - Lifecycle Methods
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
    
    // MARK: - configUI
    func configUI() {
        setupNavigationBarAppearance()
        setupTabBarAppearance()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - funcs
    private func setupNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .clear
            $0.titleTextAttributes = [.foregroundColor: Palette.podaWhite.getColor()]
            $0.shadowColor = nil
        }
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        self.navigationItem.title = "공지사항"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor(named: "podaWhite") ?? .white
        ]
    }
    
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .clear
            $0.shadowColor = nil
        }
        
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    private func getNotices() {
        dbManager.getNotices { [weak self] notices, error in
            guard let self = self else { return }
            
            if error == .none && !notices.isEmpty {
                self.notices = notices
                print("Successfully loaded \(notices.count) notices")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Error loading notices: \(String(describing: error))")
            }
        }
    }
    
    func estimateHeightForContent(content: String) -> CGFloat {
        let approximateWidthOfContent = tableView.frame.width - 40
        let size = CGSize(width: approximateWidthOfContent, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    // MARK: - objc
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - extensions
extension NoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeCell
        let notice = notices[indexPath.row]
        cell.configure(title: notice.title, date: Date.updateTime(dateTime: notice.date), content: notice.content, isContentVisible: notice.isContentVisible)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

extension NoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notice = notices[indexPath.row]
        // 셀을 클릭하면 기본 높이 + 내용 레이블 측정한 값으로 변하도록
        if notice.isContentVisible {
            let contentHeight = estimateHeightForContent(content: notice.content)
            return 80 + (contentHeight * 1.3) + 50 // 내용 잘리지 않도록 여백 추가
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notices[indexPath.row].isContentVisible.toggle() // 눌렀을 때 보이도록 전환
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
