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
    
    var pieceImageList = [UIImage(named: "piece_example1"), UIImage(named: "piece_example2"), UIImage(named: "piece_example3"), UIImage(named: "piece_example1"), UIImage(named: "piece_example2"), UIImage(named: "piece_example3")]
    
    var imageMemories: Results<ImageMemory>?
    var diaryDataList: [DiaryData] = []
    private var randomDiaryIndex = 0
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
    
    // FIXME: - 추억 조각 갯수 불러오기
    private let pieceCountLabel = UILabel().then {
        $0.setUpLabel(title: "16개", podaFont: .subhead4)  // 조각 갯수 불러오기
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
    
    // FIXME: - 추억 다이어리 갯수 불러오기
    private let diaryCountLabel = UILabel().then {
        //$0.setUpLabel(title: "0권", podaFont: .subhead4)   // 다이어리 갯수 불러오기
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseAuthManager.userLogin(email: UserDefaultManager.userEmail, password: UserDefaultManager.userPassword) { [weak self] error in
            guard let _ = self else { return }
        }
        loadImagesFromRealm()
        setPieceView()
        loadDataFromFirebase()
        print("viewwillappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        diaryDataList = []
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
    
    private let timeCapsuleImageShadowView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = Palette.podaWhite.getColor().cgColor
        $0.layer.shadowOpacity = 0.8
    }
    
    // FIXME: - 랜덤한 추억 다이어리 커버 불러오기
    private let timeCapsuleImageView = UIImageView().then {
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 20
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = Palette.podaWhite.getColor().cgColor
        $0.layer.shadowOpacity = 0.8
        $0.clipsToBounds = true
        // $0.image = 랜덤 추억 다이어리 커버
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
        //$0.backgroundColor = .green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        loadImagesFromRealm()
        configUI()
        setTimeCapsuleView()
        setDiaryView()
        setPieceView()
        diaryCollectionView.delegate = self
        diaryCollectionView.dataSource = self
        pieceCollectionView.delegate = self
        pieceCollectionView.dataSource = self
        print("viewdidload")
    }
    
    // FIXME: - Stackview 정리하기
    func configUI() {
        [mainStackView, pieceCountStackView, diaryCountStackView, scrollView].forEach {
            view.addSubview($0)
        }
        
        [statusLabel, addButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        [pieceLabel, pieceCountLabel].forEach {
            pieceCountStackView.addArrangedSubview($0)
        }
        
        [diaryLabel, diaryCountLabel].forEach {
            diaryCountStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        [diaryMenuLabel, addDiaryButton].forEach {
            diaryMenuStackView.addArrangedSubview($0)
        }
        
        [pieceMenuLabel, addPieceButton].forEach {
            pieceMenuStackView.addArrangedSubview($0)
        }
        
        [timeCapsuleLabel, emptyTimeCapsuleLabel, timeCapsuleImageView, timeCapsuleImageShadowView, diaryMenuStackView, moreDiaryButton, emptyDiaryLabel, diaryCollectionView, pieceMenuStackView, morePieceButton, emptyPieceLabel, pieceCollectionView].forEach {
            contentView.addSubview($0)
        }
        
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(7)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(36)
        }
        
        pieceCountStackView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(20)
        }
        
        diaryCountStackView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.left.equalTo(pieceCountStackView.snp.right).offset(20)
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
            $0.height.equalTo(416)
        }
        
        timeCapsuleImageShadowView.snp.makeConstraints {
            $0.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
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
    
    // FIXME: - 데이터 받아와서 조건 달기
    func setTimeCapsuleView() {
        // 생성된 다이어리가 있는 경우
        // emptyTimeCapsuleLabel.isHidden = true
        
        // 생성된 다이어리가 없는 경우
        timeCapsuleImageView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCapsuleImage))
        timeCapsuleImageView.addGestureRecognizer(tapGesture)
        timeCapsuleImageView.isUserInteractionEnabled = true
    }
    
    func setDiaryView() {
        // 생성된 다이어리가 있는 경우
        emptyDiaryLabel.isHidden = true
        
        // 생성된 다이어리가 없는 경우
        //diaryCollectionView.isHidden = true
        //timeCapsuleImageShadowView.isHidden = true
    }
    
    func setPieceView() {
        guard let pieceCount = imageMemories?.count else { return }
        if pieceCount != 0 {
            // 등록된 추억 조각이 있는 경우
            emptyPieceLabel.isHidden = true
        } else {
            // 등록된 추억 조각이 없는 경우
            pieceCollectionView.isHidden = true
        }
        print("추억 조각 갯수 = \(pieceCount)")
    }
    
    func loadImagesFromRealm() {
        imageMemories = RealmManager.shared.loadImageMemories()
        //        for imageMemory in imageMemories! {
        //            print("Image Path: \(imageMemory.imagePath ?? "No Image Path"), Memory Date: \(imageMemory.memoryDate ?? Date())")
        //        }
        pieceCollectionView.reloadData()
    }
    
    func loadDataFromFirebase() {
        firebaseDBManager.getDiaryDocuments { [weak self] diaryList, error in
            guard let self = self else { return }
            if error == .none {
                var counter = 0
                for diaryName in diaryList {
                    if diaryName != "Account" {
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
                                                self.updateUI()
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
    
    func updateUI() {
        DispatchQueue.main.async {
            self.diaryCountLabel.setUpLabel(title: "\(self.diaryDataList.count)권", podaFont: .subhead4)
            self.diaryCollectionView.reloadData()
            
            if !self.diaryDataList.isEmpty {
                self.emptyTimeCapsuleLabel.isHidden = false
                self.timeCapsuleImageView.isHidden = false
                self.randomDiaryIndex = Int.random(in: 0..<self.diaryDataList.count)
                self.timeCapsuleImageView.image = UIImage(data: self.diaryDataList[self.randomDiaryIndex].diaryImageList[0])
            }
        }
    }
    
    @objc func didTapAddButton() {
        let homeMenuViewController = HomeMenuViewController()
        homeMenuViewController.modalPresentationStyle = .overFullScreen
        present(homeMenuViewController, animated: true)
        
        homeMenuViewController.touchedDiary = {
            homeMenuViewController.dismiss(animated: true)
            self.navigationController?.pushViewController(SelectRatioViewController(), animated: true)
        }
        
        homeMenuViewController.touchedPiece = {
            homeMenuViewController.dismiss(animated: true)
            self.navigationController?.pushViewController(PieceViewController(), animated: true)
        }
    }
    
    @objc func didTapCapsuleImage() {
        let detailVC = DetailViewController()
        detailVC.diaryData = diaryDataList[randomDiaryIndex]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func didTapAddDiaryButton() {
        navigationController?.pushViewController(SelectRatioViewController(), animated: true)
    }
    
    @objc func didTapMoreDiaryButton() {
        let moreDiaryVC = MoreDiaryViewController()
        //print(diaryDataList)
        moreDiaryVC.diaryList = diaryDataList
        navigationController?.pushViewController(moreDiaryVC, animated: true)
    }
    
    @objc func didTapAddPieceButton() {
        navigationController?.pushViewController(PieceViewController(), animated: true)
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
            //추억 조각 상세 페이지로 이동
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == diaryCollectionView {
            return diaryDataList.count
        } else {
//            guard let pieceCount = imageMemories?.count else { return 0 }
//            print("Number of items in section: \(pieceCount)")
//            return pieceCount
                        return pieceImageList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == diaryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
                return UICollectionViewCell() }
            cell.titleLabel.text = diaryDataList[indexPath.row].diaryName
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieceCollectionViewCell.identifier, for: indexPath) as? PieceCollectionViewCell else { return UICollectionViewCell() }
//            guard let imageMemory = imageMemories?[indexPath.item] else { return UICollectionViewCell() }
//            let image = cell.getPieceImage(with: imageMemory)
//            cell.pieceImageView.image = image
//            return cell
                        cell.pieceImageView.image = pieceImageList[indexPath.row]
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
//            let image = cell.getPieceImage(with: imageMemory)
            //let width = image.size.width
            //print("이 이미지의 사이즈는 \(width)")
//            return CGSize(width: 150, height: collectionView.frame.height)
                        let image = pieceImageList[indexPath.row]
                        guard let image = image else { return CGSize() }
                        let width = image.size.width
                        return CGSize(width: width, height: collectionView.frame.height)
        }
    }
}

