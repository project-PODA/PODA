//
//  MorePieceViewController.swift
//  PODA
//
//  Created by 랑 on 2023/11/03.
//

import UIKit
import Then
import SnapKit
import RealmSwift

class MorePieceViewController: BaseViewController, ViewModelBindable, UIConfigurable {
   
    var viewModel: MorePieceViewModel!
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private let emptyMorePieceLabel = UILabel().then {
        $0.setUpLabel(title: "아직 추억조각이 없어요\n홈으로 돌아가 +버튼을 눌러 등록해 보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private lazy var latestPieceButton = UIButton().then {
        $0.setUpButton(title: "최신순", podaFont: .caption)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapLatestPieceButton), for: .touchUpInside)
    }
    
    private lazy var oldestPieceButton = UIButton().then {
        $0.setUpButton(title: "오래된순", podaFont: .caption)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapOldestPieceButton), for: .touchUpInside)
    }
    
    private let pieceCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.textAlignment = .center
    }
    
    private lazy var pieceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16.0
        layout.minimumLineSpacing = 16.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsVerticalScrollIndicator = false
        $0.register(MorePieceCollectionViewCell.self, forCellWithReuseIdentifier: "MorePieceCollectionViewCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let bubbleImageView = UIImageView().then {
        $0.image = UIImage(named: "image_bubble")
    }
    
    private let infoLabel = UILabel().then {
        $0.setUpLabel(title: "랜덤 조각 기능은 6개부터\n이용 가능합니다 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.textAlignment = .right
        $0.numberOfLines = 2
    }
    
    private lazy var floatingButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_randomPiece"), for: .normal)
        $0.addTarget(self, action: #selector(didTapfloatingButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setPieceUI()
        // FIXME: - viewDidLoad 될 때마다 말고 한번만 등록할 수 없나
        viewModel.registerNotification()
    }
    
    init(viewModel: MorePieceViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        [backButton, emptyMorePieceLabel, latestPieceButton, oldestPieceButton, pieceCountLabel, pieceCollectionView, bubbleImageView, infoLabel, floatingButton].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        emptyMorePieceLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        latestPieceButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(28)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }
        
        oldestPieceButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(28)
            $0.left.equalTo(latestPieceButton.snp.right).offset(5)
            $0.width.equalTo(64)
            $0.height.equalTo(28)
        }
        
        pieceCountLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(32)
            $0.right.equalToSuperview().offset(-20)
        }
        
        pieceCollectionView.snp.makeConstraints {
            $0.top.equalTo(latestPieceButton.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
        
        bubbleImageView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            $0.width.equalTo(160)
        }
        
        infoLabel.snp.makeConstraints {
            $0.centerX.equalTo(bubbleImageView)
            $0.bottom.equalTo(floatingButton.snp.top).offset(-27)
        }
        
        floatingButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.width.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    func setPieceUI() {
        let pieceCount = self.viewModel.pieceCount
        pieceCountLabel.setUpLabel(title: "총 \(pieceCount)개", podaFont: .body1)
        
        if viewModel.pieceEmptyState {
            pieceUI(true)
        } else {
            pieceUI(false)
            
            if viewModel.sortByLatest {
                viewModel.latestPieceButtonSelectedState?(true)
            } else {
                viewModel.latestPieceButtonSelectedState?(false)
            }
            
            if viewModel.pieceCountState {
                bubbleImageView.isHidden = false
                infoLabel.isHidden = false
            } else {
                bubbleImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }

    }
    
    func pieceUI(_ isHidden: Bool) {
        self.pieceCountLabel.isHidden = isHidden
        self.emptyMorePieceLabel.isHidden = !isHidden
        self.latestPieceButton.isHidden = isHidden
        self.oldestPieceButton.isHidden = isHidden
        self.pieceCollectionView.isHidden = isHidden
    }
    
    func bindViewModel() {
        // 날짜변경 업데이트 후 reload
        viewModel.pieceListLoaded = { [weak self] _ in
            guard let self else { return }
            self.pieceCollectionView.reloadData()
        }
        
        viewModel.latestPieceButtonSelectedState = { [weak self] isLatestPieceButtonOn in
            guard let self else { return }
            DispatchQueue.main.async {
                if isLatestPieceButtonOn {
                    self.oldestPieceButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                    self.oldestPieceButton.backgroundColor = Palette.podaBlack.getColor()
                    self.oldestPieceButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
                    self.latestPieceButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
                    self.latestPieceButton.backgroundColor = Palette.podaWhite.getColor()
                    self.latestPieceButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
                    self.pieceCollectionView.reloadData()
                } else {
                    self.oldestPieceButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
                    self.oldestPieceButton.backgroundColor = Palette.podaWhite.getColor()
                    self.oldestPieceButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
                    self.latestPieceButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                    self.latestPieceButton.backgroundColor = Palette.podaBlack.getColor()
                    self.latestPieceButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
                    self.pieceCollectionView.reloadData()
                }
            }
        }
    }
    
    func goToPieceSaveDeleteVC(_ index: Int) {
        let saveDeleteViewModel = SaveDeleteViewModel()
        let saveDeleteViewController = SaveDeleteViewController(viewModel: saveDeleteViewModel)
        saveDeleteViewModel.realmPieceList = viewModel.realmPieceList
        //최신순, 오래된순으로 정렬된 리스트와 그 리스트의 index를 함께 넘겨줘야함
        saveDeleteViewModel.pieceList = viewModel.sortedList
        saveDeleteViewModel.pieceIndex = index
        saveDeleteViewModel.isDiaryImage = false
        saveDeleteViewController.dateLabel.setUpLabel(title: viewModel.getPieceDate(index), podaFont: .body1)
        saveDeleteViewController.imageView.image = viewModel.getPieceImage(index)
        saveDeleteViewController.addButton.isHidden = true
        navigationController?.pushViewController(saveDeleteViewController, animated: true)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapLatestPieceButton() {
        viewModel.didTapLatestPieceButton()
    }
    
    @objc func didTapOldestPieceButton() {
        viewModel.didTapOldestPieceButton()
    }
    
    @objc func didTapfloatingButton() {
        if !viewModel.pieceCountState {
            let pieceShakeViewController = PieceShakeViewController()
            pieceShakeViewController.pieceList = viewModel.realmPieceList
            navigationController?.pushViewController(pieceShakeViewController, animated: true)
        }
    }
}

extension MorePieceViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goToPieceSaveDeleteVC(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pieceCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MorePieceCollectionViewCell.identifier, for: indexPath) as? MorePieceCollectionViewCell else { return UICollectionViewCell() }
        cell.pieceImageView.image = self.viewModel.getPieceImage(indexPath.item)
        return cell
    }
}
    
extension MorePieceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 40 - 16) / 2
        let safeAreaTop: CGFloat = view.safeAreaInsets.top
        let totalHeight: CGFloat = view.frame.height
        
        let height: CGFloat = ((totalHeight - safeAreaTop - (30 - 28 - 28 - 24) - 6)) / 4 // backButton.width = 30, pieceDateOrderButtonTopOffset = 28, pieceDateOrderButtonTopOffsetHeight = 28, collectionViewTopOffset = 24, cellSpacing = 6
        return CGSize(width: width, height: height)
    }
}

