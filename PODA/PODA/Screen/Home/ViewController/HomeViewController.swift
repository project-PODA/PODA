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
import Foundation

//UI에 보여질 데이터순.
struct DiaryData{
    var diaryName: String
    var diaryImageList: [Data]
    var createDate: String
    var ratio: String
    var description: String
}

class HomeViewController: BaseViewController, UIConfigurable {
    
//    var pieceImageList = [UIImage(named: "piece_example1"), UIImage(named: "piece_example2"), UIImage(named: "piece_example3"), UIImage(named: "piece_example1"), UIImage(named: "piece_example2"), UIImage(named: "piece_example3")]
    
    private var imageMemories: Results<ImageMemory>?
    private var diaryDataList: [DiaryData] = []
    private var randomPieceIndex = 0
    
    private let statusLabel = UILabel().then {
        $0.setUpLabel(title: "나의 추억 현황", podaFont: .head1)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let addButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 13
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    private let mainStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    private let pieceLabel = UILabel().then {
        $0.setUpLabel(title: "추억 조각", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let pieceCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let pieceCountStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let diaryLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let diaryCountLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let diaryCountStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let timeCapsuleLabel = UILabel().then {
        $0.setUpLabel(title: "오늘의 타임캡슐", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private let firebaseAuthManager = FireAuthManager(firestorageDBManager: FirestorageDBManager(), firestorageImageManager: FireStorageImageManager(imageManipulator: ImageManipulator()))
    private let firebaseDBManager = FirestorageDBManager()
    private let firebaseImageManager = FireStorageImageManager(imageManipulator: ImageManipulator())
    
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
        $0.layer.cornerRadius = 20
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private let pieceDateLabel = UILabel().then {
        $0.textColor = Palette.podaWhite.getColor()
    }

    private let diaryMenuLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private let addDiaryButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 8
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddDiaryButton), for: .touchUpInside)
    }
    
    private let diaryMenuStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    private let moreDiaryButton = UIButton().then{
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
    
    // FIXME: - 최신순으로 등록되도록
    private let diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsHorizontalScrollIndicator = false  // 스크롤바 없애기
        $0.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
    }
    
    private let pieceMenuLabel = UILabel().then {
        $0.setUpLabel(title: "추억 조각들", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
    }
    
    private let addPieceButton = UIButton().then {
        $0.backgroundColor = Palette.podaGray5.getColor()
        $0.layer.cornerRadius = 8
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = Palette.podaGray2.getColor()
        $0.addTarget(self, action: #selector(didTapAddPieceButton), for: .touchUpInside)
    }
    
    private let pieceMenuStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    private let morePieceButton = UIButton().then{
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
    
    private let pieceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.showsHorizontalScrollIndicator = false
        $0.register(PieceCollectionViewCell.self, forCellWithReuseIdentifier: "PieceCollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.isNavigationBarHidden = true
        configUI()
        setCollectionView()
        print("viewdidload")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseAuthManager.userLogin(email: UserDefaultManager.userEmail, password: UserDefaultManager.userPassword) { [weak self] error in
            guard let _ = self else { return }
        }
        loadPieceDataFromRealm()
        loadDiaryDataFromFirebase()
        print(self.navigationController?.viewControllers)
        print(imageMemories)
        print("viewwillappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        diaryDataList = []
    }
    
    // FIXME: - Stackview 정리하기
    func configUI() {
        [mainStackView, diaryCountStackView, pieceCountStackView, scrollView].forEach {
            view.addSubview($0)
        }
        
        [statusLabel, addButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        [diaryLabel, diaryCountLabel].forEach {
            diaryCountStackView.addArrangedSubview($0)
        }
        
        [pieceLabel, pieceCountLabel].forEach {
            pieceCountStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        [diaryMenuLabel, addDiaryButton].forEach {
            diaryMenuStackView.addArrangedSubview($0)
        }
        
        [pieceMenuLabel, addPieceButton].forEach {
            pieceMenuStackView.addArrangedSubview($0)
        }
        
        [timeCapsuleLabel, emptyTimeCapsuleLabel, timeCapsuleImageView, diaryMenuStackView, moreDiaryButton, emptyDiaryLabel, diaryCollectionView, pieceMenuStackView, morePieceButton, emptyPieceLabel, pieceCollectionView].forEach {
            contentView.addSubview($0)
        }
        
        timeCapsuleImageView.addSubview(pieceDateLabel)
        
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
        
        emptyTimeCapsuleLabel.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.height.equalTo(416)
        }
        
        timeCapsuleImageView.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(416)
        }
        
    // FIXME: - 랜덤한 위치에 띄우기
        pieceDateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-80)
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
        
        // FIXME: - cell size 정한 후 height 수정하기
        pieceCollectionView.snp.makeConstraints {
            $0.top.equalTo(pieceMenuStackView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }
        
        morePieceButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(pieceCollectionView.snp.top).offset(-16)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(pieceCountStackView.snp.bottom).offset(30)
            $0.left.right.bottom.equalToSuperview()
        }
        
        // FIXME: - 추억 조각들 아래에 탭바 크기만큼의 투명한 뷰를 추가하기 or collectionview 아래에 마진 주기
        contentView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(1080)    // 스크롤 가능 높이 조절하기 > 추억 조각들 아래에 탭바 크기만큼의 투명한 뷰를 추가하기
        }
    }
    
    func setCollectionView() {
        diaryCollectionView.delegate = self
        diaryCollectionView.dataSource = self
        pieceCollectionView.delegate = self
        pieceCollectionView.dataSource = self
    }
    
    // FIXME: - memories > piece로 통일?
    // FIXME: - 랜덤 이미지 표시 주기 하루에 한번으로 가능한지 확인하기
    func loadPieceDataFromRealm() {
        imageMemories = RealmManager.shared.loadImageMemories()
        //        for imageMemory in imageMemories! {
        //            print("Image Path: \(imageMemory.imagePath ?? "No Image Path"), Memory Date: \(imageMemory.memoryDate ?? Date())")
        //        }
        guard let pieceCount = imageMemories?.count else { return }
        print("추억 조각 갯수 = \(pieceCount)")
        self.pieceCountLabel.setUpLabel(title: "\(pieceCount)개", podaFont: .subhead4)
        if pieceCount != 0 {
            // 등록된 추억 조각이 있는 경우
            // 타임캡슐 뷰 업데이트
            emptyTimeCapsuleLabel.isHidden = true
            timeCapsuleImageView.isHidden = false
            
            self.randomPieceIndex = Int.random(in: 0..<pieceCount)
            
            guard let imageMemory = self.imageMemories?[self.randomPieceIndex] else { return }
            self.timeCapsuleImageView.image = self.getPieceImage(with: imageMemory)
            self.pieceDateLabel.setUpLabel(title: self.getPieceDate(with: imageMemory), podaFont: .subhead2)
            
            //            pieceImageList 더미데이터 사용하는 경우
            //            let randomPieceIndex = Int.random(in: 0..<self.pieceImageList.count)
            //            guard let randomImage = self.pieceImageList[randomPieceIndex] else { return }
            //            self.timeCapsuleImageView.image = randomImage
            //            self.pieceCountLabel.text = "\(pieceImageList.count)개"
                        
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCapsuleImage))
            timeCapsuleImageView.addGestureRecognizer(tapGesture)
            timeCapsuleImageView.isUserInteractionEnabled = true
            
            // 추억 조각들 뷰 업데이트
            emptyPieceLabel.isHidden = true
            pieceCollectionView.isHidden = false
            
            pieceCollectionView.reloadData()
        } else {
            // 등록된 추억 조각이 없는 경우
            emptyTimeCapsuleLabel.isHidden = false
            timeCapsuleImageView.isHidden = true
            emptyPieceLabel.isHidden = false
            pieceCollectionView.isHidden = true
        }
    }
    
    // FIXME: - diaryCountLabel 한번만 설정하도록
    func loadDiaryDataFromFirebase() {
        firebaseDBManager.getDiaryDocuments { [weak self] diaryList, error in
            guard let self = self else { return }
            if error == .none {
                // FIXME: - counter 변수 확인
                print("diaryList: \(diaryList)")
                var counter = 0
                if diaryList.count == 1 {
                    //account라는 document 하나는 default로 있으므로 dairyList.count == 1 이면 추가된 다이어리는 0이라는 의미
                    DispatchQueue.main.async {
                        self.emptyDiaryLabel.isHidden = false
                        self.diaryCollectionView.isHidden = true
                        self.diaryCountLabel.setUpLabel(title: "0권", podaFont: .subhead4)
                    }
                }
                for diaryName in diaryList {
                    if diaryName != "account" {
                        firebaseDBManager.getDiaryData(diaryNameList: [diaryName]) { [weak self] diaryInfoList, error in
                            guard let self = self else { return }
                            if error == .none, let diaryInfo = diaryInfoList.first {
                                firebaseImageManager.getDiaryImage(dinaryName: diaryInfo.diaryName) { [weak self] error, imageList in
                                    guard let self = self else { return }
                                    //print(imageList)
                                    if error == .none {
                                        self.diaryDataList.append(DiaryData(diaryName: diaryInfo.diaryName, diaryImageList: imageList, createDate: Date.updateTime(dateTime: diaryInfo.createTime).replacingOccurrences(of: "-", with: "."), ratio: "square", description: diaryInfo.description))
                                        counter += 1
                                        if counter == diaryList.count - 1 {
                                            self.diaryDataList.sort { $0.createDate > $1.createDate }
                                            DispatchQueue.main.async {
                                                self.diaryCountLabel.setUpLabel(title: "\(self.diaryDataList.count)권", podaFont: .subhead4)
                                                self.emptyDiaryLabel.isHidden = true
                                                self.diaryCollectionView.isHidden = false
                                                self.diaryCollectionView.reloadData()
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
        guard let imagePath = imageMemory.imagePath else { return UIImage() }
        guard let pieceImage = UIImage(contentsOfFile: imagePath) else { return UIImage() }
        return pieceImage
    }
    
    func getPieceDate(with imageMemory: ImageMemory) -> String {
        guard let memoryDate = imageMemory.memoryDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        return dateFormatter.string(from: memoryDate)
    }
    
    // FIXME: - MoreDiaryVC, DetailVC에서 사용됨
    func goToDiarySaveDeleteVC(_ index: Int) {
        guard let imageMemory = self.imageMemories?[index] else { return }
        let saveDeleteVC = SaveDeleteViewController()
        saveDeleteVC.imageView.image = getPieceImage(with: imageMemory)
        saveDeleteVC.dateLabel.text = getPieceDate(with: imageMemory)
        saveDeleteVC.indexPath = index
        saveDeleteVC.addButton.isHidden = true
        saveDeleteVC.isDiaryImage = false
        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
    
    // FIXME: - Bind 함수로 정리하기
    func goToPieceSaveDeleteVC(_ index: Int) {
        guard let imageMemory = self.imageMemories?[index] else { return }
        let saveDeleteVC = SaveDeleteViewController()
        saveDeleteVC.imageView.image = getPieceImage(with: imageMemory)
        saveDeleteVC.dateLabel.text = getPieceDate(with: imageMemory)
        saveDeleteVC.indexPath = index
        saveDeleteVC.addButton.isHidden = true
        saveDeleteVC.isDiaryImage = false
        navigationController?.pushViewController(saveDeleteVC, animated: true)
    }
    
    @objc func didTapAddButton() {
        let homeMenuViewController = HomeMenuViewController()
        homeMenuViewController.modalPresentationStyle = .overFullScreen
        present(homeMenuViewController, animated: true)
        
        homeMenuViewController.touchedDiary = {
            self.dismiss(animated: true)
            self.navigationController?.pushViewController(SelectRatioViewController(), animated: true)
        }
        
        homeMenuViewController.touchedPiece = {
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
        print(diaryDataList)
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
            guard let pieceCount = imageMemories?.count else { return 0 }
            print("Number of items in section: \(pieceCount)")
            return pieceCount
//            return pieceImageList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == diaryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
                return UICollectionViewCell() }
            cell.titleLabel.setUpLabel(title: diaryDataList[indexPath.row].diaryName, podaFont: .subhead3)
            print("test\(indexPath.row): \(diaryDataList[indexPath.row].diaryName)")
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieceCollectionViewCell.identifier, for: indexPath) as? PieceCollectionViewCell else { return UICollectionViewCell() }
            guard let imageMemory = imageMemories?[indexPath.item] else { return UICollectionViewCell() }
            let image = getPieceImage(with: imageMemory)
            cell.pieceImageView.image = image
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
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieceCollectionViewCell.identifier, for: indexPath) as? PieceCollectionViewCell else { return CGSize() }
//            guard let imageMemory = imageMemories?[indexPath.item] else { return CGSize() }
//            let image = getPieceImage(with: imageMemory)
//            let width = image.size.width
//            print("이 이미지의 사이즈는 \(width)")
            let width = (view.frame.width / 2.5) - 32
            return CGSize(width: width, height: collectionView.frame.height)
//                        let image = pieceImageList[indexPath.row]
//                        guard let image = image else { return CGSize() }
//                        let width = image.size.width
//                        return CGSize(width: width, height: collectionView.frame.height)
        }
    }
}

