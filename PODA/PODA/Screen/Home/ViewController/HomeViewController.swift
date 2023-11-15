//
//  HomeViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/16.
//

import UIKit
import Then
import SnapKit
import NVActivityIndicatorView

class HomeViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    var viewModel: HomeViewModel!
    
    private lazy var loadingIndicator = CustomLoadingIndicator()
    
    private let statusLabel = UILabel().then {
        $0.setUpLabel(title: "나의 추억 현황", podaFont: .head1)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var addButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 13
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    private let pieceLabel = UILabel().then {
        $0.setUpLabel(title: "추억 조각", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let pieceCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let diaryLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let diaryCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let timeCapsuleLabel = UILabel().then {
        $0.setUpLabel(title: "오늘의 타임캡슐", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private let pieceDateImageView = UIImageView().then {
        $0.image = UIImage(named: "image_speechBubblePodaBlue")
    }
    
    private let pieceDateLabel = UILabel().then {
        $0.textColor = Palette.podaBlue.getColor()
    }
    
    private let emptyTimeCapsuleLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리와 추억 조각을 만들고\n타임캡슐을 받아보세요 !", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let timeCapsuleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    private let diaryMenuLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private lazy var addDiaryButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 8
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddDiaryButton), for: .touchUpInside)
    }
    
    private lazy var moreDiaryButton = UIButton().then{
        $0.setUpButton(title: "더보기", podaFont: .subhead1)
        $0.titleLabel?.textColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapMoreDiaryButton), for: .touchUpInside)
    }
    
    private let emptyDiaryLabel = UILabel().then {
        $0.setUpLabel(title: "아직 다이어리가 없어요\n+버튼을 눌러 만들어보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private lazy var diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsHorizontalScrollIndicator = false  // 스크롤바 없애기
        $0.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let pieceMenuLabel = UILabel().then {
        $0.setUpLabel(title: "추억 조각", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private lazy var addPieceButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 8
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddPieceButton), for: .touchUpInside)
    }
    
    private lazy var morePieceButton = UIButton().then{
        $0.setUpButton(title: "더보기", podaFont: .subhead1)
        $0.titleLabel?.textColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapMorePieceButton), for: .touchUpInside)
    }
    
    private let emptyPieceLabel = UILabel().then {
        $0.setUpLabel(title: "아직 추억조각이 없어요\n+버튼을 눌러 등록해 보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
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
    
    private lazy var pieceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsHorizontalScrollIndicator = false
        $0.register(PieceCollectionViewCell.self, forCellWithReuseIdentifier: "PieceCollectionViewCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        viewModel.loadDiaryData()
        viewModel.registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(loadingIndicator)
        viewModel.login()
        // FIXME: - loadPieceData도 viewDidLoad에서만 호출해도 될 듯. pieceVC에서 realm에 추가, 업데이트 & 홈의 pieceList에도 추가, 업데이트 한다면..
        viewModel.loadPieceData()
        setPieceUI()
        viewModel.diaryDataLoaded?()
    }
    
    init(viewModel: HomeViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        let mainStackView = UIStackView(arrangedSubviews: [statusLabel, addButton]).then {
            $0.axis = .horizontal
            $0.alignment = .center
        }
        
        let diaryCountStackView = UIStackView(arrangedSubviews: [diaryLabel, diaryCountLabel]).then {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 4
        }
        
        let pieceCountStackView = UIStackView(arrangedSubviews: [pieceLabel, pieceCountLabel]).then {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 4
        }
        
        let diaryMenuStackView = UIStackView(arrangedSubviews: [diaryMenuLabel, addDiaryButton]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }
        
        let pieceMenuStackView = UIStackView(arrangedSubviews: [pieceMenuLabel, addPieceButton]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }
        
        [loadingIndicator, mainStackView, diaryCountStackView, pieceCountStackView, scrollView].forEach {
            view.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        [timeCapsuleLabel, pieceDateLabel, pieceDateImageView, emptyTimeCapsuleLabel, timeCapsuleImageView, diaryMenuStackView, moreDiaryButton, emptyDiaryLabel, diaryCollectionView, pieceMenuStackView, morePieceButton, emptyPieceLabel, oldestPieceButton, latestPieceButton, pieceCollectionView].forEach {
            contentView.addSubview($0)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(7)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(36)
        }
        
        diaryCountStackView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(20)
        }
        
        pieceCountStackView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.left.equalTo(diaryCountStackView.snp.right).offset(20)
        }
        
        timeCapsuleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
        }
        
        pieceDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.centerX.equalTo(pieceDateImageView)
        }
        
        pieceDateImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            //$0.left.equalTo(timeCapsuleLabel.snp.right).offset(68)
            $0.right.equalToSuperview().offset(-24)
            $0.width.equalTo(140)
            $0.height.equalTo(44)
        }
        
        emptyTimeCapsuleLabel.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(416)
        }
       
        timeCapsuleImageView.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(416)
        }
        
        addDiaryButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }
        
        diaryMenuStackView.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleImageView.snp.bottom).offset(60)
            $0.left.equalToSuperview().offset(20)
        }
        
        emptyDiaryLabel.snp.makeConstraints {
            $0.top.equalTo(diaryMenuStackView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(108)
        }
        
        diaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(diaryMenuStackView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo((view.frame.width / 5 - 2) * 1.35)
        }
        
        moreDiaryButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(diaryCollectionView.snp.top).offset(-16)
        }
        
        addPieceButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }
        
        pieceMenuStackView.snp.makeConstraints {
            $0.top.equalTo(diaryCollectionView.snp.bottom).offset(60)
            $0.left.equalToSuperview().offset(20)
        }
        
        morePieceButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(pieceCollectionView.snp.top).offset(-54)
        }
        
        emptyPieceLabel.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }
        
        latestPieceButton.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }
        
        oldestPieceButton.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(12)
            $0.left.equalTo(latestPieceButton.snp.right).offset(5)
            $0.width.equalTo(64)
            $0.height.equalTo(28)
        }
        
        // FIXME: - cell size 정한 후 height 수정하기
        pieceCollectionView.snp.makeConstraints {
            $0.top.equalTo(oldestPieceButton.snp.bottom).offset(18)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(pieceCountStackView.snp.bottom).offset(30)
            $0.left.right.bottom.equalToSuperview()
        }
        
        // FIXME: - 추억 조각들 아래에 탭바 크기만큼의 투명한 뷰를 추가하기 or collectionview 아래에 마진 주기
        contentView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(1132)
        }
    }

    
    func setPieceUI() {
        let pieceCount = self.viewModel.pieceCount
        self.pieceCountLabel.setUpLabel(title: "\(pieceCount)개", podaFont: .subhead4)
        
        if viewModel.pieceEmptyState {
            pieceUI(true)
            viewModel.sortByLatest = true
            contentView.snp.updateConstraints {
                $0.height.equalTo(1132)
            }
        } else {
            pieceUI(false)
            contentView.snp.updateConstraints {
                $0.height.equalTo(1152)
            }
            
            if viewModel.sortByLatest {
                viewModel.latestPieceButtonSelectedState?(true)
            } else {
                viewModel.latestPieceButtonSelectedState?(false)
            }
            
            let randomPieceIndex = self.viewModel.randomPieceIndex
            let pieceInfo = self.viewModel.pieceList[randomPieceIndex ?? 0]
            timeCapsuleImageView.image = pieceInfo.image
            pieceDateLabel.setUpLabel(title: "\(pieceInfo.pieceDate)의 조각", podaFont: .subhead2)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCapsuleImage))
            timeCapsuleImageView.addGestureRecognizer(tapGesture)
            timeCapsuleImageView.isUserInteractionEnabled = true
        }
    }
    
    func pieceUI(_ isHidden: Bool) {
        emptyTimeCapsuleLabel.isHidden = !isHidden
        timeCapsuleImageView.isHidden = isHidden
        pieceDateImageView.isHidden = isHidden
        pieceDateLabel.isHidden = isHidden
        emptyPieceLabel.isHidden = !isHidden
        pieceCollectionView.isHidden = isHidden
        oldestPieceButton.isHidden = isHidden
        latestPieceButton.isHidden = isHidden
    }

    func bindViewModel() {
        // 다이어리 데이터가 바뀔 때마다 얘를 다시 호출, 데이터 변경이 완료된 후 클로저에서 어떤 걸 실행할 지 정해주기
        // 이렇게 돼면 다이어리 하나가 추가될 때마다 UI 업데이트되고 collectionView도 리로드돼서 비효율적임. 1,2,3,4권 이런식으로 UI 업데이트가 눈에 다 보임
        // 데이터가 다 불러와지면 업데이트하기 위해서 HomeViewModel 'if diaryCount == totalDiaryCount' 부분을 구현함
//        viewModel.diaryDataLoaded = { [weak self] _ in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                //self.setDiaryUI()
//                let diaryCount = self.viewModel.diaryCount
//                self.diaryCountLabel.setUpLabel(title: "\(diaryCount)권", podaFont: .subhead4)
//                self.diaryCollectionView.reloadData()
//            }
//        }
        
        viewModel.diaryDataLoaded = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.viewModel.diaryEmptyState {
                    self.emptyDiaryLabel.isHidden = false
                    self.diaryCollectionView.isHidden = true
                    self.diaryCountLabel.setUpLabel(title: "0권", podaFont: .subhead4)
                } else {
                    self.emptyDiaryLabel.isHidden = true
                    self.diaryCollectionView.isHidden = false
                    self.diaryCountLabel.setUpLabel(title: "\(self.viewModel.diaryCount)권", podaFont: .subhead4)
                    self.viewModel.sortDiaryList()
                    self.diaryCollectionView.reloadData()
                }
            }
        }
        
        viewModel.loadingIndicatorState = { [weak self] isLoading in
            guard let self else { return }
            DispatchQueue.main.async {
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
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
    
    func goToPieceSaveDeleteVC(_ index: Int, _ pieceList: [PieceData]) {
        // MVC 에서는 saveDeleteVC.indexPath = index 이렇게 직접 전달하지만, MVVM 에서는 직접 값을 전달하는게 아니라 다음 뷰가 필요한 뷰모델을 전달해줘야함
        let saveDeleteViewModel = SaveDeleteViewModel()
        let saveDeleteViewController = SaveDeleteViewController(viewModel: saveDeleteViewModel)
        saveDeleteViewModel.realmPieceList = viewModel.realmPieceList
        saveDeleteViewModel.pieceList = pieceList
        saveDeleteViewModel.pieceIndex = index
        saveDeleteViewModel.isDiaryImage = false
        saveDeleteViewController.dateLabel.setUpLabel(title: pieceList[index].pieceDate, podaFont: .body1)
        saveDeleteViewController.imageView.image = pieceList[index].image
        saveDeleteViewController.addButton.isHidden = true
        navigationController?.pushViewController(saveDeleteViewController, animated: true)
        // present 는 viewController만 가지고 있음. 그래서 뷰컨에서는 self.present 이런식으로 쓸 수 있지만 뷰모델에서는 사용 불가 그래서 메서드 만들때 fromCurrentVC로 뷰컨을 받은 다음 fromCurrentVC.present 이런식으로 사용해야함
    }
    
    @objc func didTapAddButton() {
        let homeMenuViewController = HomeMenuViewController()
        homeMenuViewController.modalPresentationStyle = .overFullScreen
        present(homeMenuViewController, animated: true)
        
        homeMenuViewController.didTapQR = {
            self.dismiss(animated: true)
            let qrViewController = QRViewController()
            qrViewController.modalPresentationStyle = .overFullScreen
            self.present(qrViewController, animated: true)
        }
        
        homeMenuViewController.didTapDiary = {
            self.dismiss(animated: true)
            self.navigationController?.pushViewController(SelectRatioViewController(viewModel: CreateDiaryViewModel()), animated: true)
        }
        
        homeMenuViewController.didTapPiece = {
            self.dismiss(animated: true)
            self.navigationController?.pushViewController(SelectRatioViewController(viewModel: CreateDiaryViewModel()), animated: true)
        }
    }
    
    @objc func didTapCapsuleImage() {
        goToPieceSaveDeleteVC(viewModel.randomPieceIndex ?? 0, viewModel.pieceList)
    }
    
    @objc func didTapAddDiaryButton() {
        navigationController?.pushViewController(SelectRatioViewController(viewModel: CreateDiaryViewModel()), animated: true)
    }
    
    @objc func didTapMoreDiaryButton() {
        let moreDiaryViewModel = MoreDiaryViewModel()
        let moreDiaryViewController = MoreDiaryViewController(viewModel: moreDiaryViewModel)
        if viewModel.diaryEmptyState {
            moreDiaryViewController.emptyMoreDiaryLabel.isHidden = false
            moreDiaryViewController.moreDiaryCollectionView.isHidden = true
            moreDiaryViewController.deleteButton.isHidden = true
        } else {
            moreDiaryViewController.emptyMoreDiaryLabel.isHidden = true
            moreDiaryViewController.moreDiaryCollectionView.isHidden = false
            moreDiaryViewController.deleteButton.isHidden = false
            moreDiaryViewModel.diaryList = viewModel.diaryList
        }
        navigationController?.pushViewController(moreDiaryViewController, animated: true)  // >> MVVM에서 뷰 전환을 뷰모델이 해야한다 뷰컨이 해야한다 정해져있는거 아님. 우리는 유경님 말대로 뷰컨에서 하기로 함
    }
    
    @objc func didTapAddPieceButton() {
        //let pieceViewModel = PieceViewModel() (MVVM 패턴 적용 후)
        let pieceViewController = PieceViewController() //(viewModel: pieceViewModel)
        pieceViewController.isComeFromSaveDeleteVC = false
        pieceViewController.imageView.isUserInteractionEnabled = true
        navigationController?.pushViewController(pieceViewController, animated: true)
    }
    
    @objc func didTapMorePieceButton() {
        let morePieceViewModel = MorePieceViewModel()
        let morePieceViewController = MorePieceViewController(viewModel: morePieceViewModel)
        morePieceViewModel.realmPieceList = viewModel.realmPieceList
        morePieceViewModel.pieceList = viewModel.pieceList
        morePieceViewController.bind(to: morePieceViewController.viewModel)
        navigationController?.pushViewController(morePieceViewController, animated: true)
    }
    
    @objc func didTapLatestPieceButton() {
        // 뷰 모델한테 탭 됐다고 알려주기
        viewModel.didTapLatestPieceButton()
    }
    
    @objc func didTapOldestPieceButton() {
        viewModel.didTapOldestPieceButton()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == diaryCollectionView {
            let detailViewModel = DetailViewModel()
            let detailViewController = DetailViewController(viewModel: detailViewModel)
            detailViewModel.diaryData = viewModel.getDiaryData(indexPath.row)
            navigationController?.pushViewController(detailViewController, animated: true)
        } else {
            goToPieceSaveDeleteVC(indexPath.row, viewModel.sortedList)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == diaryCollectionView {
            return viewModel.diaryCount
        } else {
            return viewModel.pieceCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == diaryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
                return UICollectionViewCell() }
            let diaryName = viewModel.getDiaryName(indexPath.row)
            cell.titleLabel.setUpLabel(title: diaryName, podaFont: .subhead3)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieceCollectionViewCell.identifier, for: indexPath) as? PieceCollectionViewCell else { return UICollectionViewCell() }
            
            cell.pieceImageView.image = viewModel.sortedList[indexPath.item].image
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == diaryCollectionView {
            let width = (view.frame.width / 5) - 2
            return CGSize(width: width, height: width * 1.35)
        } else {
            let width = (view.frame.width / 2.5) - 32
            return CGSize(width: width, height: collectionView.frame.height)
        }
    }
}

