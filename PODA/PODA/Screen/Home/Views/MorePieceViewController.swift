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
    
    var pieceList: Results<RealmPieceData>?
    private var isSortedByPieceDate = true
    
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
    
    private lazy var pieceDateOrderButton = UIButton().then {
        $0.setUpButton(title: "추억날짜순", podaFont: .caption)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapPieceDateOrderButton), for: .touchUpInside)
    }
    
    private lazy var createDateOrderButton = UIButton().then {
        $0.setUpButton(title: "등록순", podaFont: .caption)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapCreateDateOrderButton), for: .touchUpInside)
    }
    
    private let pieceCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
        $0.textAlignment = .center
    }
    
    private lazy var pieceAlbumCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
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
    }
    
    init(viewModel: MorePieceViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        [backButton, emptyMorePieceLabel, pieceDateOrderButton, createDateOrderButton, pieceCountLabel, pieceAlbumCollectionView, bubbleImageView, infoLabel, floatingButton].forEach {
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
        
        pieceDateOrderButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(28)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(72)
            $0.height.equalTo(28)
        }
        
        createDateOrderButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(28)
            $0.left.equalTo(pieceDateOrderButton.snp.right).offset(5)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }
        
        pieceCountLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(32)
            $0.right.equalToSuperview().offset(-20)
        }
        
        pieceAlbumCollectionView.snp.makeConstraints {
            $0.top.equalTo(pieceDateOrderButton.snp.bottom).offset(24)
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
    
//    func setPieceUI() {
//        print("setPieceUI 실행됨")
//        let pieceCount = self.viewModel.pieceCount
//        self.pieceCountLabel.setUpLabel(title: "총 \(pieceCount)개", podaFont: .body1)
//        
//        if viewModel.pieceEmptyState {
//            self.pieceCountLabel.isHidden = true
//            self.emptyMorePieceLabel.isHidden = false
//            self.pieceDateOrderButton.isHidden = true
//            self.createDateOrderButton.isHidden = true
//            self.pieceAlbumCollectionView.isHidden = true
//        } else {
//            self.pieceCountLabel.isHidden = false
//            self.emptyMorePieceLabel.isHidden = true
//            self.pieceDateOrderButton.isHidden = false
//            self.createDateOrderButton.isHidden = false
//            self.pieceAlbumCollectionView.isHidden = false
//            
//            print("MorePieceVC 172 isSortedByPieceDate: \(isSortedByPieceDate)")
//            if self.viewModel.isSortedByPieceDate {
//                self.viewModel.selectedOrderOptionState?(true)
//            } else {
//                self.viewModel.selectedOrderOptionState?(false)
//            }
//            
//            if viewModel.pieceCountState {
//                bubbleImageView.isHidden = false
//                infoLabel.isHidden = false
//            } else {
//                bubbleImageView.isHidden = true
//                infoLabel.isHidden = true
//            }
//        }
//    }
    
    func setPieceUI(_ isHidden: Bool) {
        self.pieceCountLabel.isHidden = isHidden
        self.emptyMorePieceLabel.isHidden = !isHidden
        self.pieceDateOrderButton.isHidden = isHidden
        self.createDateOrderButton.isHidden = isHidden
        self.pieceAlbumCollectionView.isHidden = isHidden
    }
    
    func bindViewModel() {
        viewModel.pieceListLoaded = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                let pieceCount = self.viewModel.pieceCount
                self.pieceCountLabel.setUpLabel(title: "총 \(pieceCount)개", podaFont: .body1)
                
                if self.viewModel.pieceEmptyState {
                    self.setPieceUI(true)
                } else {
                    self.setPieceUI(false)
                    
                    if self.viewModel.isSortedByPieceDate {
                        self.viewModel.selectedOrderOptionState?(true)
                    } else {
                        self.viewModel.selectedOrderOptionState?(false)
                    }
                    
                    if self.viewModel.pieceCountState {
                        self.bubbleImageView.isHidden = false
                        self.infoLabel.isHidden = false
                    } else {
                        self.bubbleImageView.isHidden = true
                        self.infoLabel.isHidden = true
                    }
                }
            }
        }
        
        viewModel.selectedOrderOptionState = { [weak self] isPieceDateOrderButtonOn in
            guard let self else { return }
            DispatchQueue.main.async {
                if isPieceDateOrderButtonOn {
                    self.createDateOrderButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                    self.createDateOrderButton.backgroundColor = Palette.podaBlack.getColor()
                    self.createDateOrderButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
                    self.pieceDateOrderButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
                    self.pieceDateOrderButton.backgroundColor = Palette.podaWhite.getColor()
                    self.pieceDateOrderButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
                    self.pieceAlbumCollectionView.reloadData()
                } else {
                    self.createDateOrderButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
                    self.createDateOrderButton.backgroundColor = Palette.podaWhite.getColor()
                    self.createDateOrderButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
                    self.pieceDateOrderButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
                    self.pieceDateOrderButton.backgroundColor = Palette.podaBlack.getColor()
                    self.pieceDateOrderButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
                    self.pieceAlbumCollectionView.reloadData()
                }
            }
        }
    }
    
    func goToPieceSaveDeleteVC(_ index: Int) {
        let saveDeleteViewModel = SaveDeleteViewModel()
        let saveDeleteViewController = SaveDeleteViewController(viewModel: saveDeleteViewModel)
        saveDeleteViewModel.realmPieceList = viewModel.realmPieceList
        saveDeleteViewModel.pieceList = viewModel.pieceList
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
    
    @objc func didTapPieceDateOrderButton() {
        viewModel.didTapPieceDateOrderButton()
    }
    
    @objc func didTapCreateDateOrderButton() {
        viewModel.didTapCreateDateOrderButton()
    }
    
    // FIXME: - 고치기
    @objc func didTapfloatingButton() {
        if !viewModel.pieceCountState {
            let pieceShakeViewController = PieceShakeViewController()
            pieceShakeViewController.pieceList = pieceList
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

