//
//  ProfileViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import UIKit

class ProfileViewController: BaseViewController,ViewModelBindable,UIConfigurable {
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
    
    init(viewModel : ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(coder.debugDescription)
    }
    
    func bindViewModel() {
        
    }
    
    func configUI() {
        
    }
}
