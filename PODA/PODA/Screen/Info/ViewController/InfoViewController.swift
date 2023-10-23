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
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "infoCell")
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

        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white

        return cell
    }
}

// MARK: - UITableViewDelegate
extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
