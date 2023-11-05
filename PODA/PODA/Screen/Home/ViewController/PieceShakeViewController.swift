//
//  PieceShakeViewController.swift
//  PODA
//
//  Created by FUTURE on 2023/11/03.
//

import UIKit
import SnapKit
import RealmSwift
import Then


class PieceShakeViewController: BaseViewController, UIConfigurable {
    
    private var floatingImages: [(imageView: UIImageView, vector: CGVector)] = []
    
    
    // Realm 데이터베이스에서 불러온 ImageMemory 객체를 저장할 변수 선언
    var pieceList: Results<ImageMemory>?
    
    // 백 버튼을 위한 lazy var 선언, 실제 사용될 때 초기화됨
    private lazy var backButton = UIButton().then {
        // 버튼에 이미지 설정, .normal 상태일 때 "icon_back" 이미지 사용
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        // 버튼이 탭되었을 때 실행될 메서드(didTapBackButton) 연결
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private let translucentView = UIView().then {
        $0.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.8)
        let fingerImageView = UIImageView().then {
            $0.image = UIImage(named: "icon_finger")
            $0.contentMode = .scaleAspectFill
        }
        let infoLabel = UILabel().then {
            $0.setUpLabel(title: "추억 조각들을 마음대로 드래그해보세요 !", podaFont: .caption)
            $0.textColor = Palette.podaWhite.getColor()
        }
        
        [fingerImageView, infoLabel].forEach($0.addSubview)
        
        fingerImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(140)
        }
        infoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(fingerImageView.snp.bottom).offset(20)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayRandomImages()
        configUI()
        hideTranslucentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupFloatingImages()
        startFloatingAnimation()
    }
    
    func configUI() {
        [backButton, translucentView].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        translucentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true) // 네비게이션 스택에서 현재 뷰 컨트롤러를 팝
    }
    
    @objc func didTapTranslucentView() {
        translucentView.isHidden = true
    }
    
    // 팬 제스처 인식기 업데이트를 처리하는 메서드
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        switch gesture.state {
        case .began, .changed:
            // 손가락으로 이미지 이동
            let translation = gesture.translation(in: view)
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            gesture.setTranslation(.zero, in: view)
        case .ended:
            // 속도를 계산하고 새로운 벡터로 설정
            var velocity = gesture.velocity(in: view)
            // 최대 속도를 제한
            let maxSpeed: CGFloat = 550.0
            velocity.x = max(min(velocity.x, maxSpeed), -maxSpeed)
            velocity.y = max(min(velocity.y, maxSpeed), -maxSpeed)
            let vector = CGVector(dx: velocity.x / 200, dy: velocity.y / 300) // 속도 값을 관리하기 쉬운 숫자로 줄임
            
            // floatingImages 배열을 업데이트하여 이 imageView의 새 벡터로 설정
            for i in 0..<floatingImages.count {
                if floatingImages[i].imageView == imageView {
                    floatingImages[i].vector = vector
                    break
                }
            }
        default:
            break
        }
    }
    
    private func hideTranslucentView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTranslucentView))
        translucentView.addGestureRecognizer(tapGesture)
    }
    
    // 이미지를 랜덤하게 표시하는 메서드
    private func displayRandomImages() {
        guard let pieceList = pieceList, pieceList.count >= 6 else { return }
        
        let imageViewSize = CGSize(width: 300, height: 300) // 이미지 뷰의 크기
        var usedIndexes = Set<Int>() // 사용된 인덱스를 추적하기 위한 집합
        
        while usedIndexes.count < 6 {
            let randomPieceIndex = Int(arc4random_uniform(UInt32(pieceList.count)))
            
            // 이미 사용된 인덱스인 경우 루프의 다음 반복으로 이동
            if usedIndexes.contains(randomPieceIndex) {
                continue
            }
            
            // 새 인덱스를 usedIndexes 집합에 추가
            usedIndexes.insert(randomPieceIndex)
            
            // 랜덤하게 선택된 ImageMemory 객체로부터 이미지를 불러옴
            let imageMemory = pieceList[randomPieceIndex]
            let image = getPieceImage(with: imageMemory)
            
            // UIImageView 생성 및 초기 설정
            let imageView = UIImageView(image: image).then {
                $0.contentMode = .scaleAspectFit // 이미지의 비율을 유지하면서 뷰에 맞춤
                $0.isUserInteractionEnabled = true // 사용자 상호작용 활성화
            }
            
            view.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                let maxX = view.bounds.width - imageViewSize.width
                let maxY = view.bounds.height - imageViewSize.height
                
                let randomX = CGFloat(arc4random_uniform(UInt32(maxX)))
                let randomY = CGFloat(arc4random_uniform(UInt32(maxY)))
                make.left.equalTo(view.snp.left).offset(randomX)
                make.top.equalTo(view.snp.top).offset(randomY)
                make.width.height.equalTo(imageViewSize)
            }
            
            // UIPanGestureRecognizer 추가
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            imageView.addGestureRecognizer(panGesture)
            
            // 랜덤한 각도를 계산하여 이미지 뷰에 적용
            let randomAngle = CGFloat.random(in: -40...40) * .pi / 180
            imageView.transform = CGAffineTransform(rotationAngle: randomAngle)
        }
    }
    
    // 이미지 뷰를 초기화하고 움직임 벡터를 설정하는 메서드
    private func setupFloatingImages() {
        for imageView in self.view.subviews.compactMap({ $0 as? UIImageView }) {
            // backButton과 translucentView를 제외하고 floatingImages 배열에 추가
            guard imageView != backButton.imageView, imageView != translucentView.subviews.first(where: { $0 is UIImageView }) else { continue }
            
            let speed = CGFloat.random(in: 0.1...0.4) // 속도 랜덤하게 설정
            let vector = CGVector(dx: speed * (Bool.random() ? 1 : -1), dy: speed * (Bool.random() ? 1 : -1))
            floatingImages.append((imageView, vector))
        }
    }
    
    // 애니메이션 시작하는 메서드
    private func startFloatingAnimation() {
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.add(to: .main, forMode: .default)
    }
    
    
    // 각 프레임마다 호출되는 메서드
    @objc private func step(displayLink: CADisplayLink) {
        for (imageView, vector) in floatingImages {
            var newVector = vector
            
            // 이미지 뷰의 새 위치 계산
            var newCenter = imageView.center
            newCenter.x += vector.dx
            newCenter.y += vector.dy
            
            // 화면의 경계에 도달했는지 확인하고 벡터를 반전시킴
            if newCenter.x < 0 || newCenter.x > view.bounds.width {
                newVector.dx = -vector.dx
            }
            if newCenter.y < 0 || newCenter.y > view.bounds.height {
                newVector.dy = -vector.dy
            }
            
            // 이미지 뷰와 벡터를 업데이트
            imageView.center = newCenter
            if newVector != vector {
                for i in 0..<floatingImages.count {
                    if floatingImages[i].imageView == imageView {
                        floatingImages[i].vector = newVector
                        break
                    }
                }
            }
        }
    }
  
    
    // ImageMemory 객체로부터 UIImage를 가져오는 메서드
    func getPieceImage(with imageMemory: ImageMemory) -> UIImage {
        // 파일 이름과 문서 디렉토리 경로를 확인하여 이미지 데이터를 로드
        guard let fileName = imageMemory.imagePath,
              let documentDirectory = RealmManager.shared.getDocumentDirectory() else {
            return UIImage() // 조건에 맞지 않는 경우 빈 UIImage 반환
        }
        
        // 이미지 파일 경로를 조합
        let filePath = documentDirectory.appendingPathComponent(fileName).path
        
        do {
            // 파일 경로에서 데이터를 로드
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            // 데이터로부터 UIImage 생성 시도
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            // 이미지 로딩 중 에러 발생 시 콘솔에 에러 메시지 출력
            print("이미지 로딩 실패: \(error.localizedDescription)")
        }
        return UIImage() // 이미지 로딩에 실패한 경우 빈 UIImage 반환
    }
}