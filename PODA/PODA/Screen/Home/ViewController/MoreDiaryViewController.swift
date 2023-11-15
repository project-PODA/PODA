//
//  MoreDiaryViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/18.
//

import UIKit
import Then
import SnapKit

class MoreDiaryViewController: BaseViewController, UIConfigurable {
    
    var viewModel: MoreDiaryViewModel!
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    lazy var deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_trash"), for: .normal)
        $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
    
    let emptyMoreDiaryLabel = UILabel().then {
        $0.setUpLabel(title: "아직 다이어리가 없어요\n홈으로 돌아가 +버튼을 눌러 만들어보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    lazy var  moreDiaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12.0  // 셀 옆 간격
        layout.minimumLineSpacing = 12.0  // 셀 위 아래 간격
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsHorizontalScrollIndicator = false
        $0.register(MoreDiaryCollectionViewCell.self, forCellWithReuseIdentifier: "MoreDiaryCollectionViewCell")
        $0.delegate = self
        $0.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    init(viewModel: MoreDiaryViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // FIXME: - 삭제 기능 구현하면 deleteButton 추가
    func configUI() {
        [backButton, emptyMoreDiaryLabel, moreDiaryCollectionView].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
//        deleteButton.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide)
//            $0.right.equalToSuperview().offset(-20)
//            $0.width.height.equalTo(30)
//        }
        
        emptyMoreDiaryLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        moreDiaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28)
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapDeleteButton() {
        // 삭제하는 로직은 delegate에
    }
}


extension MoreDiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 40) * 2 / 3
        let safeAreaTop: CGFloat = view.safeAreaInsets.top
        let safeAreaBottom: CGFloat = view.safeAreaInsets.bottom
        let totalHeight: CGFloat = view.frame.height
        
        let height: CGFloat = ((totalHeight - safeAreaTop - safeAreaBottom - 30 - 12 - 28) - 12) / 2  // backButton.width = 30, collectionViewTopOffset = 12, collectionViewBottomOffset = 28, cellSpacing = 12
        return CGSize(width: width, height: height)
    }
}

extension MoreDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.diaryCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoreDiaryCollectionViewCell.identifier, for: indexPath) as? MoreDiaryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.diaryCoverImageView.image = viewModel.getDiaryImage(indexPath.row)
        cell.titleLabel.setUpLabel(title: viewModel.getDiaryName(indexPath.row), podaFont: .head1)
        cell.dateLabel.setUpLabel(title: viewModel.getDiaryDate(indexPath.row), podaFont: .subhead2)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let saveDeleteViewModel = SaveDeleteViewModel()
        let saveDeleteViewController = SaveDeleteViewController(viewModel: saveDeleteViewModel)
        saveDeleteViewModel.isDiaryImage = true
        saveDeleteViewModel.diaryData = viewModel.diaryList[indexPath.row]
        saveDeleteViewController.imageView.image = viewModel.getDiaryImage(indexPath.row)
        saveDeleteViewController.dateLabel.text = viewModel.getDiaryDate(indexPath.row)
        saveDeleteViewController.editButton.isHidden = true
        navigationController?.pushViewController(saveDeleteViewController, animated: true)
    }
}
