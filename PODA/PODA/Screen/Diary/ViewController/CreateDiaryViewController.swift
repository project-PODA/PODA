//
//  CreateDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then

class CreateDiaryViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    // MARK: - Properties
    
    var viewModel: CreateDiaryViewModel!
    var ratio: Ratio!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    init(viewModel: CreateDiaryViewModel, ratio: Ratio) {
        self.viewModel = viewModel
        self.ratio = ratio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    func configUI() {
        
    }
    
    // MARK: - Custom Method
    
    func bindViewModel() {
        
    }

}
