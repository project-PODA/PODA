//
//  MainViewController.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import UIKit

class MainViewController: BaseViewController,ViewModelBindable,UIConfigurable {
    
    
    var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    init(viewModel : MainViewModel) {
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
