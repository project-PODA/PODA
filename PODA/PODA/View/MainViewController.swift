//
//  MainViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import UIKit
import SnapKit

class MainViewController: BaseViewController,ViewModelBindable,UIConfigurable {
    var viewModel: MainViewModel!
    private lazy var moveNextButton : UIButton = {
        let button = UIButton()
        button.setUpButton(title: "이동")
        button.addTarget(self, action: #selector(moveToCompletsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var label : UILabel = {
        let label = UILabel()
        label.setUpLabel(title: "라벨임", fontSize: .medium)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var textField : UITextField = {
        let textField = UITextField()
        textField.setUpTextField(delegate: self)
        textField.backgroundColor = .gray
        textField.placeholder = "텍스트를 입력하시오"
        return textField
    }()
    
    private lazy var customView : UIView = {
        let view = UIView()
        view.setUpView()
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.setupableView(delegate: self, dataSource: self, cellType: CustomCell.self)
        return tableView
    }()
    
    private lazy var clearButton : UIButton = {
        let clear = UIButton()
        clear.setUpButton(title: "초기화")
        clear.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return clear
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        viewModel.fetchTestData(apiUrl: "https://jsonplaceholder.typicode.com/posts/1")
    }
    
    init(viewModel : MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(coder.debugDescription)
    }
    
    func bindViewModel() {
        viewModel.labelText.addObserver { [weak self] text in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.label.text = text
            }
        }
        viewModel.postData.addObserver { [weak self] postData in
            guard let self = self, let postData = postData else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func configUI() {
        [moveNextButton,label,textField,customView,tableView,clearButton].forEach(view.addSubview)
        moveNextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.width.height.equalTo(50)
        }
        label.snp.makeConstraints {
            $0.top.equalTo(moveNextButton.snp.bottom).offset(20)
            $0.centerX.equalTo(moveNextButton)
            $0.height.equalTo(50)
            $0.width.equalTo(300)
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20)
            $0.centerX.equalTo(label)
            $0.height.equalTo(50)
            $0.width.equalTo(150)
        }
        customView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(20)
            $0.centerX.equalTo(textField)
            $0.width.height.equalTo(100)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(customView.snp.bottom).offset(20)
            $0.centerX.equalTo(customView)
            $0.width.height.equalTo(200)
        }
        clearButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(20)
            $0.centerX.equalTo(tableView)
            $0.width.height.equalTo(100)
        }
    }
}
extension MainViewController{
    @objc private func moveToCompletsButtonTapped(){
        let mainVC = MainViewController(viewModel: MainViewModel(networkManager: NetworkManager()))
        mainVC.bind(to: mainVC.viewModel)
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    @objc private func clearButtonTapped(){
        viewModel.clearText()
    }
    
}
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postData.value == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomCell.self), for: indexPath) as? CustomCell else {
            return UITableViewCell()
        }
        if let postData = viewModel.postData.value{
            cell.id.text = String(postData.id)
            cell.body.text = postData.body
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0 // 중요한건 아니지만 재사용될 테이블이 있다면 enum같은걸로 관리하는게 좋을것 같습니다.
    }
}

extension MainViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text{
            viewModel.setText(text: text)
        }
        return true
    }
}

class CustomCell : UITableViewCell{
    lazy var id : UILabel = {
        let label = UILabel()
        label.setUpLabel(title: "", fontSize: .medium)
        return label
    }()
    lazy var body : UILabel = {
        let label = UILabel()
        label.setUpLabel(title: "", fontSize: .medium)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [id,body].forEach(contentView.addSubview)
        id.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(10)
            $0.leading.equalTo(contentView).offset(10)
            $0.width.height.equalTo(50)
        }
        body.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(10)
            $0.leading.equalTo(id.snp.trailing)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(50)
            
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
