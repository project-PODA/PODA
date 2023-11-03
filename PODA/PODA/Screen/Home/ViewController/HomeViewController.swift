//
//  HomeViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/16.
//

import UIKit
import Then
import SnapKit
import RealmSwift
import NVActivityIndicatorView


// UI에 보여질 데이터순.
struct DiaryData: Equatable {
    var diaryName: String
    var diaryImageList: [Data]
    var createDate: String
    var ratio: String
    var description: String
}

class HomeViewController: BaseViewController, UIConfigurable {
    
    private let firebaseAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    private var diaryDataList: [DiaryData] = []
    
    private var pieceList: Results<ImageMemory>?
    private var isSortedByPieceDate = true
    private let localRealm = try! Realm()
    private var randomPieceIndex = 0
    
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
        $0.setUpLabel(title: "아직 다이어리가 없어요\n생성하기를 통해 만들어보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 5
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
        $0.setUpLabel(title: "추억 조각들", podaFont: .head1)
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
        $0.setUpLabel(title: "아직 추억조각이 없어요\n생성하기를 통해 만들어보세요 :)", podaFont: .caption)
        $0.textColor = Palette.podaGray3.getColor()
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
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
        loadDiaryDataFromFirebase()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(loadingIndicator)
        firebaseAuthManager.userLogin(email: UserDefaultManager.userEmail, password: UserDefaultManager.userPassword) { [weak self] error in
            guard let _ = self else { return }
        }
        loadPieceDataFromRealm()
        updateUI()
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
        
        // FIXME: - 추억 조각 더보기 드래그 기능 구현 후 morePieceButton 추가하기
        [timeCapsuleLabel, pieceDateLabel, pieceDateImageView, emptyTimeCapsuleLabel, timeCapsuleImageView, diaryMenuStackView, moreDiaryButton, emptyDiaryLabel, diaryCollectionView, pieceMenuStackView, emptyPieceLabel, createDateOrderButton, pieceDateOrderButton, pieceCollectionView].forEach {
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
            $0.right.equalToSuperview().offset(-35)
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
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
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
        
        emptyPieceLabel.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }
        
        pieceDateOrderButton.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(72)
            $0.height.equalTo(28)
        }
        
        createDateOrderButton.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(12)
            $0.left.equalTo(pieceDateOrderButton.snp.right).offset(5)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }
        
        // FIXME: - cell size 정한 후 height 수정하기
        pieceCollectionView.snp.makeConstraints {
            $0.top.equalTo(createDateOrderButton.snp.bottom).offset(18)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }
        
//        morePieceButton.snp.makeConstraints {
//            $0.right.equalToSuperview().offset(-20)
//            $0.bottom.equalTo(pieceCollectionView.snp.top).offset(-16)
//        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(pieceCountStackView.snp.bottom).offset(30)
            $0.left.right.bottom.equalToSuperview()
        }
        
        // FIXME: - 추억 조각들 아래에 탭바 크기만큼의 투명한 뷰를 추가하기 or collectionview 아래에 마진 주기
        contentView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(1120)    // 스크롤 가능 높이 조절하기 > 추억 조각들 아래에 탭바 크기만큼의 투명한 뷰를 추가하기
        }
    }
    
    func pieceDateOrderButtonOn() {
        createDateOrderButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        createDateOrderButton.backgroundColor = Palette.podaBlack.getColor()
        createDateOrderButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
        pieceDateOrderButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
        pieceDateOrderButton.backgroundColor = Palette.podaWhite.getColor()
        pieceDateOrderButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
    }
    
    func createDateOrderButtonOn() {
        createDateOrderButton.setTitleColor(Palette.podaBlack.getColor(), for: .normal)
        createDateOrderButton.backgroundColor = Palette.podaWhite.getColor()
        createDateOrderButton.layer.borderColor = Palette.podaWhite.getColor().cgColor
        pieceDateOrderButton.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        pieceDateOrderButton.backgroundColor = Palette.podaBlack.getColor()
        pieceDateOrderButton.layer.borderColor = Palette.podaGray4.getColor().cgColor
    }
    
    func updateUI() {
        if diaryDataList.isEmpty {
            updateDiaryCollectionView(isEmpty: true)
        } else {
            updateDiaryCollectionView(isEmpty: false)
        }
    }
    
    func updateDiaryCollectionView(isEmpty: Bool) {
        if isEmpty {
            emptyDiaryLabel.isHidden = false
            diaryCollectionView.isHidden = true
            diaryCountLabel.setUpLabel(title: "0권", podaFont: .subhead4)
        } else {
            diaryDataList.sort { $0.createDate > $1.createDate }
            diaryCountLabel.setUpLabel(title: "\(self.diaryDataList.count)권", podaFont: .subhead4)
            emptyDiaryLabel.isHidden = true
            diaryCollectionView.isHidden = false
            diaryCollectionView.reloadData()
        }
    }
    
    // FIXME: - memories > piece로 통일?
    // FIXME: - 랜덤 이미지 표시 주기 하루에 한번으로 가능한지 확인하기
    func loadPieceDataFromRealm() {
        pieceList = RealmManager.shared.loadImageMemories()
        //        for imageMemory in imageMemories! {
        //            print("Image Path: \(imageMemory.imagePath ?? "No Image Path"), Memory Date: \(imageMemory.memoryDate ?? Date())")
        //        }
        guard let pieceCount = pieceList?.count else { return }
        //print("추억 조각 갯수 = \(pieceCount)")
        self.pieceCountLabel.setUpLabel(title: "\(pieceCount)개", podaFont: .subhead4)
        if pieceCount != 0 {
            // 등록된 추억 조각이 있는 경우
            // 타임캡슐 뷰 업데이트
            emptyTimeCapsuleLabel.isHidden = true
            timeCapsuleImageView.isHidden = false
            pieceDateImageView.isHidden = false
            pieceDateLabel.isHidden = false
            
            self.randomPieceIndex = Int.random(in: 0..<pieceCount)
            
            guard let imageMemory = self.pieceList?[self.randomPieceIndex] else { return }
            self.timeCapsuleImageView.image = self.getPieceImage(with: imageMemory)
            self.pieceDateLabel.setUpLabel(title: "\(self.getPieceDate(with: imageMemory))의 조각", podaFont: .subhead2)
                        
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCapsuleImage))
            timeCapsuleImageView.addGestureRecognizer(tapGesture)
            timeCapsuleImageView.isUserInteractionEnabled = true
            
            // 추억 조각들 뷰 업데이트
            emptyPieceLabel.isHidden = true
            pieceCollectionView.isHidden = false
            createDateOrderButton.isHidden = false
            pieceDateOrderButton.isHidden = false
            contentView.snp.updateConstraints {
                $0.height.equalTo(1140)
            }
            
            if isSortedByPieceDate {
                pieceDateOrderButtonOn()
            } else {
                createDateOrderButtonOn()
            }
            
            pieceCollectionView.reloadData()
            
        } else {
            // 등록된 추억 조각이 없는 경우
            emptyTimeCapsuleLabel.isHidden = false
            timeCapsuleImageView.isHidden = true
            pieceDateImageView.isHidden = true
            pieceDateLabel.isHidden = true
            emptyPieceLabel.isHidden = false
            pieceCollectionView.isHidden = true
            createDateOrderButton.isHidden = true
            pieceDateOrderButton.isHidden = true
            isSortedByPieceDate = true
            contentView.snp.updateConstraints {
                $0.height.equalTo(1120)
            }
        }
    }
    
    // FIXME: - diaryCountLabel 한번만 설정하도록
    func loadDiaryDataFromFirebase() {
        loadingIndicator.startAnimating()

        firebaseDBManager.getDiaryDocuments { [weak self] diaryList, error in
            guard let self = self else { return }
            
            if error == .none {
                // FIXME: - counter 변수 확인
                print("diaryList: \(diaryList)")
                var counter = 0
                if diaryList.count == 1 {
                    // account라는 document 하나는 default로 있으므로 dairyList.count == 1 이면 추가된 다이어리는 0이라는 의미
                    DispatchQueue.main.async {
                        self.updateDiaryCollectionView(isEmpty: true)
                        self.loadingIndicator.stopAnimating()
                    }
                }
                for diaryName in diaryList {
                    if diaryName != "account" {
                        firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { [weak self] diaryInfoList, error in
                            guard let self = self else { return }
                            if error == .none, let diaryInfo = diaryInfoList.first {
                                firebaseImageManager.getDiaryImage(dinaryName: diaryInfo.diaryName) { [weak self] error, imageList in
                                    guard let self = self else { return }
                                    if error == .none {
                                        self.diaryDataList.append(DiaryData(
                                            diaryName: diaryInfo.diaryName,
                                            diaryImageList: imageList,
                                            createDate: diaryInfo.createTime,
                                            ratio: diaryInfo.frameRate,
                                            description: diaryInfo.description)
                                        )
                                        counter += 1
                                        if counter == diaryList.count - 1 {
                                            DispatchQueue.main.async {
                                                self.updateDiaryCollectionView(isEmpty: false)
                                                self.loadingIndicator.stopAnimating()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getPieceImage(with imageMemory: ImageMemory) -> UIImage {
        guard let fileName = imageMemory.imagePath,
              let documentDirectory = RealmManager.shared.getDocumentDirectory() else {
            return UIImage()
        }
        
        let filePath = documentDirectory.appendingPathComponent(fileName).path
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            print("이미지 로딩 실패: \(error.localizedDescription)")
        }
        return UIImage()
    }
    
    func getPieceDate(with imageMemory: ImageMemory) -> String {
        guard let memoryDate = imageMemory.memoryDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: memoryDate)
    }
    
    // FIXME: - MoreDiaryVC, DetailVC에서 사용됨
    func goToDiarySaveDeleteVC(_ index: Int) {
//        guard let pieceList = self.pieceList?[index] else { return }
//        let saveDeleteVC = SaveDeleteViewController()
//        saveDeleteVC.imageView.image = getPieceImage(with: imageMemory)
//        saveDeleteVC.dateLabel.text = getPieceDate(with: imageMemory)
//        saveDeleteVC.indexPath = index
//        saveDeleteVC.addButton.isHidden = true
//        saveDeleteVC.isDiaryImage = false
//        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
    
    // FIXME: - Bind 함수로 정리하기
    func goToPieceSaveDeleteVC(_ index: Int) {
        guard let imageMemory = self.pieceList?[index] else { return }
        let saveDeleteVC = SaveDeleteViewController()
        saveDeleteVC.dateLabel.setUpLabel(title: getPieceDate(with: imageMemory), podaFont: .body1)
        saveDeleteVC.imageView.image = getPieceImage(with: imageMemory)
        saveDeleteVC.pieceList = pieceList
        saveDeleteVC.indexPath = index
        saveDeleteVC.addButton.isHidden = true
        saveDeleteVC.isDiaryImage = false
        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCreateNotification), name: DetailDiaryViewController.createDiaryNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteNotification), name: SaveDeleteViewController.deleteDiaryNotificationName, object: nil)
    }
    
    @objc func handleCreateNotification(_ notification: NSNotification) {
        if let diaryData = notification.object as? DiaryData {
            self.diaryDataList.append(diaryData)
        }
    }
    
    @objc func handleDeleteNotification(_ notification: NSNotification) {
        if let diaryData = notification.object as? DiaryData {
            if let targetIndex = self.diaryDataList.firstIndex(of: diaryData) {
                self.diaryDataList.remove(at: targetIndex)
            }
        }
    }
    
    @objc func didTapAddButton() {
        let homeMenuVC = HomeMenuViewController()
        homeMenuVC.modalPresentationStyle = .overFullScreen
        present(homeMenuVC, animated: true)
        
        // FIXME: - 실기기 테스트 해보고 화면 전환 방식 변경
        homeMenuVC.didTapQR = {
            self.dismiss(animated: true)
            let qrVC = QRViewController()
            qrVC.modalPresentationStyle = .overFullScreen
            self.present(qrVC, animated: true)
        }
        
        homeMenuVC.didTapDiary = {
            self.dismiss(animated: true)
            self.navigationController?.pushViewController(SelectRatioViewController(), animated: true)
        }
        
        homeMenuVC.didTapPiece = {
            self.dismiss(animated: true)
            self.navigationController?.pushViewController(PieceViewController(), animated: true)
        }
    }
    
    @objc func didTapCapsuleImage() {
        goToPieceSaveDeleteVC(randomPieceIndex)
    }
    
    @objc func didTapAddDiaryButton() {
        navigationController?.pushViewController(SelectRatioViewController(), animated: true)
    }
    
    // FIXME: - Bind 함수로 정리하기
    @objc func didTapMoreDiaryButton() {
        let moreDiaryVC = MoreDiaryViewController()
        if diaryDataList.isEmpty {
            moreDiaryVC.emptyMoreDiaryLabel.isHidden = false
            moreDiaryVC.moreDiaryCollectionView.isHidden = true
            moreDiaryVC.deleteButton.isHidden = true
        } else {
            moreDiaryVC.emptyMoreDiaryLabel.isHidden = true
            moreDiaryVC.moreDiaryCollectionView.isHidden = false
            moreDiaryVC.deleteButton.isHidden = false
            moreDiaryVC.diaryList = diaryDataList
        }
        navigationController?.pushViewController(moreDiaryVC, animated: true)
    }
    
    // FIXME: - Bind 함수로 정리하기
    @objc func didTapAddPieceButton() {
        let pieceVC = PieceViewController()
        pieceVC.imageView.isUserInteractionEnabled = true
        navigationController?.pushViewController(pieceVC, animated: true)
    }
    
    @objc func didTapMorePieceButton() {
        navigationController?.pushViewController(MorePieceViewController(), animated: true)
    }
    
    @objc func didTapPieceDateOrderButton() {
        isSortedByPieceDate = true
        pieceDateOrderButtonOn()
        pieceCollectionView.reloadData()
    }
    
    @objc func didTapCreateDateOrderButton() {
        isSortedByPieceDate = false
        createDateOrderButtonOn()
        pieceCollectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == diaryCollectionView {
            if indexPath.row < diaryDataList.count {
                let detailVC = DetailViewController()
                detailVC.diaryData = diaryDataList[indexPath.row]
                navigationController?.pushViewController(detailVC, animated: true)
            }
        } else {
            goToPieceSaveDeleteVC(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == diaryCollectionView {
            return diaryDataList.count
        } else {
            guard let pieceCount = pieceList?.count else { return 0 }
            return pieceCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == diaryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
                return UICollectionViewCell() }
            cell.titleLabel.setUpLabel(title: diaryDataList[indexPath.row].diaryName, podaFont: .subhead3)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieceCollectionViewCell.identifier, for: indexPath) as? PieceCollectionViewCell else { return UICollectionViewCell() }
            if !isSortedByPieceDate {
                pieceList = localRealm.objects(ImageMemory.self).sorted(byKeyPath: "createDate", ascending: false)  // true 인 경우 과거 > 최신 / 등록순
                guard let imageMemory = pieceList?[indexPath.item] else { return UICollectionViewCell() }
                let image = getPieceImage(with: imageMemory)
                cell.pieceImageView.image = image
                return cell
            } else {
                pieceList = localRealm.objects(ImageMemory.self).sorted(byKeyPath: "memoryDate", ascending: false)  // true 인 경우 과거 > 최신 / 추억날짜순
                guard let imageMemory = pieceList?[indexPath.item] else { return UICollectionViewCell() }
                let image = getPieceImage(with: imageMemory)
                cell.pieceImageView.image = image
                return cell
            }
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

