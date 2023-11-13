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
    var pieceList: [RealmPieceData]?
    
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
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
    
    
    private lazy var captureButton = UIButton().then {
        $0.setUpButton(title: "화면캡쳐 📸", podaFont: .button1)
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.setTitleColor(Palette.podaWhite.getColor(), for: .normal)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(captureScreen), for: .touchUpInside)
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
        [backButton, captureButton, translucentView].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
        
        translucentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    @objc func captureScreen() {
        // 버튼을 숨기고 캡쳐
        backButton.isHidden = true
        captureButton.isHidden = true
        
        // 화면 캡쳐
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 버튼 다시 보이게 함
        backButton.isHidden = false
        captureButton.isHidden = false
        
        // 갤러리에 이미지 저장
        if let imageToSave = image {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    
    // 이미지 저장 완료 처리
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 에러 발생시 토스트 메시지로 알림
            showToastMessage("저장 오류: \(error.localizedDescription)", withDuration: 3.0, delay: 0)
        } else {
            // 성공 메시지 토스트로 표시
            showToastMessage("이미지가 갤러리에 저장되었습니다.", withDuration: 3.0, delay: 0)
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
    
    
    private func showToastMessage(_ message: String, withDuration: Double, delay: Double) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.center.x - 100, y: self.view.center.y, width: 200, height: 36))
        toastLabel.setUpLabel(title: message, podaFont: .caption)
        toastLabel.textColor = Palette.podaWhite.getColor()
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = Palette.podaBlack.getColor().withAlphaComponent(0.7)
        toastLabel.layer.cornerRadius = 7.0
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
            let pieceInfo = pieceList[randomPieceIndex]
            let image = getPieceImage(with: pieceInfo)
            
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
    
    
    // ImageMemory 객체로부터 UIImage를 가져오는 메서드
    private func getPieceImage(with pieceInfo: RealmPieceData) -> UIImage {
        // 파일 이름과 문서 디렉토리 경로를 확인하여 이미지 데이터를 로드
        guard let fileName = pieceInfo.imagePath,
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
