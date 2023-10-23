//
//  InfoViewController.swift
//  PODA
//
//  Created by t2023-m0080 on 2023/10/22.
//
//test
import UIKit

class InfoViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    var viewModel: InfoViewModel!
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(InfoCell.self, forCellReuseIdentifier: "infoCell")
        return tv
    }()
    
    
    private let items: [String] = ["버전", "개인정보처리방침", "공지사항", "기능 추가 요청/오류 신고", "만든이", "탈퇴하기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindViewModel()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func bindViewModel() {
    }
    
    func configUI() {
        tableView.backgroundColor = .clear
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBackButton))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
