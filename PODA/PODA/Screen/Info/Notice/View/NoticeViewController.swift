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

class NoticeViewController: BaseViewController, UIConfigurable, ViewModelBindable {
    
    
    var viewModel: NoticeViewModel!
    
    init(viewModel: NoticeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(NoticeCell.self, forCellReuseIdentifier: "noticeCell")
        $0.backgroundColor = .clear
    }
    
    
    // MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let baseTabbar = self.tabBarController as? BaseTabbarController {
            baseTabbar.setCustomTabbarHidden(true)
        }
        viewModel.getNotices()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setTableView()
    }
    
    func setTableView() {
        tableView.setUpTableView(delegate: self, dataSource: self, cellType: NoticeCell.self)
    }
    
    // MARK: - configUI
    func configUI() {
        setupNavigationBarAppearance()
        setupTabBarAppearance()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    
    // MARK: - bindViewModel
    func bindViewModel() {
        viewModel.onNoticesChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
    
    
    // MARK: - objc
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - extensions
extension NoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeCell
        let notice = viewModel.notices[indexPath.row]
        
        let formattedDate = viewModel.formattedDate(notice.date)
        cell.configure(title: notice.title, date: formattedDate, content: notice.content, isContentVisible: notice.isContentVisible)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}


extension NoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notice = viewModel.notices[indexPath.row]
        // 셀을 클릭하면 기본 높이 + 내용 레이블 측정한 값으로 변하도록
        if notice.isContentVisible {
            let contentHeight = viewModel.estimateHeightForContent(content: notice.content, width: tableView.frame.width)
            return 90 + (contentHeight * 1.35)
        } else {
            return 80
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleContentVisibility(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
