//
//  HomeViewController.swift
//  PODA
//
//  Created by 랑 on 2023/10/16.
//

import UIKit
import Then
import SnapKit

class HomeViewController: BaseViewController, UIConfigurable {
    
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
        $0.setUpLabel(title: "16개", podaFont: .subhead4)  //조각 갯수 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let pieceLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let diaryLabel = UILabel().then {
        $0.setUpLabel(title: "추억 다이어리", podaFont: .body1)
        $0.textColor = Palette.podaGray3.getColor()
    }
    
    private let diaryCountLabel = UILabel().then {
        $0.setUpLabel(title: "20권", podaFont: .subhead4)   //다이어리 갯수 불러오기
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private let diaryLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let timeCapsuleLabel = UILabel().then {
        $0.setUpLabel(title: "오늘의 타임캡슐", podaFont: .head1)
        $0.textColor = Palette.podaGray1.getColor()
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
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 20
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = Palette.podaWhite.getColor().cgColor
        $0.layer.shadowOpacity = 0.8
        // $0.image = 랜덤 다이어리 커버
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCapsuleImage))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
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
    
    private let diaryStackView = UIStackView().then {
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
    
    private let diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width / 5) - 2
        layout.itemSize = CGSize(width: width, height: 104) // height = collectionView.frame.height 으로 변경.. 비율 계산해서 적어주기,,
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
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
    
    private let pieceStackView = UIStackView().then {
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
    
    private let pieceImageView = UIImageView().then {
        $0.backgroundColor = Palette.podaGray6.getColor()
        $0.layer.cornerRadius = 5
        let diaryLabel = UILabel()
        diaryLabel.setUpLabel(title: "아직 추억조각이 없어요\n생성하기를 통해 만들어보세요 :)", podaFont: .caption)
        diaryLabel.textColor = Palette.podaGray3.getColor()
        diaryLabel.numberOfLines = 2
        diaryLabel.textAlignment = .center
        $0.addSubview(diaryLabel)
        diaryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private let pieceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width / 5) - 2
        layout.itemSize = CGSize(width: width, height: 104) // height = collectionView.frame.height 으로 변경.. 비율 계산해서 적어주기,,
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2.0
        $0.collectionViewLayout = layout
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "PieceCollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        configUI()
        setTimeCapsuleView()
        diaryCollectionView.delegate = self
        diaryCollectionView.dataSource = self
    }
    
    func configUI() {
        [mainStackView, pieceLabelStackView, diaryLabelStackView, scrollView].forEach(view.addSubview)
        [statusLabel, addButton].forEach(mainStackView.addArrangedSubview)
        [pieceLabel, pieceCountLabel].forEach(pieceLabelStackView.addArrangedSubview)
        [diaryLabel, diaryCountLabel].forEach(diaryLabelStackView.addArrangedSubview)
        scrollView.addSubview(contentView)
        [diaryMenuLabel, addDiaryButton].forEach(diaryStackView.addArrangedSubview)
        [pieceMenuLabel, addPieceButton].forEach(pieceStackView.addArrangedSubview)
        [timeCapsuleLabel, emptyTimeCapsuleLabel, timeCapsuleImageView, diaryStackView, moreDiaryButton, emptyDiaryLabel, diaryCollectionView, pieceStackView, morePieceButton, pieceImageView].forEach(contentView.addSubview)

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(7)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        pieceLabelStackView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }
        
        diaryLabelStackView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(16)
            make.left.equalTo(pieceLabelStackView.snp.right).offset(20)
        }
        
        timeCapsuleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        emptyTimeCapsuleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(416)
        }
        
        timeCapsuleImageView.snp.makeConstraints { make in
            make.top.equalTo(timeCapsuleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(416)
        }
        
        addDiaryButton.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        
        diaryStackView.snp.makeConstraints { make in
            make.top.equalTo(timeCapsuleImageView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(20)
        }
        
        emptyDiaryLabel.snp.makeConstraints { make in
            make.top.equalTo(diaryStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(108)
        }
        
        diaryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(diaryStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(108)
        }
        
        moreDiaryButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(diaryCollectionView.snp.top).offset(-16)
        }
        
        addPieceButton.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        
        pieceStackView.snp.makeConstraints { make in
            make.top.equalTo(diaryCollectionView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(20)
        }
        
        pieceImageView.snp.makeConstraints { make in
            make.top.equalTo(pieceStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(180)
        }
        
        morePieceButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(pieceImageView.snp.top).offset(-16)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(pieceLabelStackView.snp.bottom).offset(30)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(1080)    // 스크롤 가능 높이 조절하기
        }
    }
    
    func setTimeCapsuleView() {
        // 생성된 다이어리가 있는 경우
        // emptyTimeCapsuleLabel.isHidden = true
        
        // 생성된 다이어리가 없는 경우
        timeCapsuleImageView.isHidden = true
    }
    
    func setDiaryView() {
        // 생성된 다이어리가 있는 경우
        // emptyDiaryLabel.isHidden = true
        
        // 생성된 다이어리가 없는 경우
        diaryCollectionView.isHidden = true
    }
    
    func setPieceView() {
        // 등록된 추억 조각이 있는 경우
        // emptyPieceLabel.isHidden = true
        
        // 등록된 추억 조각이 없는 경우
        pieceCollectionView.isHidden = true
    }
    
    @objc func didTapAddButton() {
        let homeMenuViewController = HomeMenuViewController()
        homeMenuViewController.modalPresentationStyle = .overFullScreen
        present(homeMenuViewController, animated: true)
        
        homeMenuViewController.touchedPiece = {
            homeMenuViewController.dismiss(animated: true)
            self.navigationController?.pushViewController(PieceViewController(), animated: true)
        }
    }
    
    @objc func didTapCapsuleImage() {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
    
    @objc func didTapAddDiaryButton() {
        // 추억 다이어리 만들기 페이지로 이동
    }
    
    @objc func didTapMoreDiaryButton() {
        navigationController?.pushViewController(MoreDiaryViewController(), animated: true)
    }
    
    @objc func didTapAddPieceButton() {
        // 추억 조각 등록하기 페이지로 이동
        navigationController?.pushViewController(PieceViewController(), animated: true)
    }
    
    @objc func didTapMorePieceButton() {
        navigationController?.pushViewController(MorePieceViewController(), animated: true)
    }

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else { return UICollectionViewCell() }
        
        //titleLabel.text = indexPath.row의 title
        //cell.imageView.image = imageList[indexPath.row]
        
        return cell
    }
}

//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellWidth = (view.frame.width / 5) - 2 // (view.frame.width / 3) - 2 > 3등분 후에 옆 간격(2)만큼 빼주기
//        return CGSize(width: cellWidth, height: collectionView.frame.height)
//    }
//    
//    //셀 간 옆 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 2.0
//    }
//}

