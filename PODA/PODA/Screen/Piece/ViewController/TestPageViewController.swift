////
////  TestPageViewController.swift
////  PODA
////
////  Created by Kyle on 2023/10/18.
////
//
//import UIKit
//import SnapKit
//import Then
//import RealmSwift
//
//class TestPageViewController: BaseViewController, UIConfigurable {
//
//    var imageMemories: Results<ImageMemory>?
////    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
////        ($0.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
////    }
//
//    let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return collectionView
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        configUI()
//    }
//
//    func configUI() {
//        view.backgroundColor = Palette.podaGray1.getColor()
//
//        view.addSubview(collectionView)
//
//        collectionView.snp.makeConstraints {
//            $0.left.equalToSuperview().offset(20)
//            $0.right.equalToSuperview().offset(-20)
//            $0.height.equalTo(200)
//            $0.centerY.equalToSuperview()
//        }
//
//        collectionView.delegate = self
//        collectionView.dataSource = self
//    }
//}
//
//extension TestPageViewController: UICollectionViewDelegate {
//
//}
//
//extension TestPageViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        imageMemories?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}
//
//
////func loadImagesFromRealm() {
////    // Realm에서 이미지 메모리를 불러오기
////    imageMemories = RealmManager.shared.realm.objects(ImageMemory.self)
////
////    collectionView.reloadData()
////}
//
////func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? Cell else {
////        fatalError("Cell 캐스팅 실패")
////    }
////
////    // 이미지 메모리에서 이미지 경로 가져오기
////    if let imagePath = imageMemories?[indexPath.item].imagePath {
////        // 이미지 로드 및 설정
////        if let image = UIImage(contentsOfFile: imagePath) {
////            cell.imageView.image = image
////        }
////    }
////
////    return cell
////}
