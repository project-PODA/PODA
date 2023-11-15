//
//  OnboardingViewController.swift
//  PODA
//
//  Created by FUTURE on 11/15/23.
//

import UIKit
import SnapKit
import Then

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    private lazy var scrollView = UIScrollView().then {
        $0.delegate = self
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var pageControl = UIPageControl().then {
        $0.numberOfPages = 5 // 온보딩 이미지 개수
        $0.currentPage = 0
    }
    
    
    private lazy var skipButton = UIButton().then {
        $0.setUpButton(title: "건너뛰기", podaFont: .button1)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)
    }
    
    private lazy var nextButton = UIButton().then {
        $0.setUpButton(title: "다음", podaFont: .button1)
        $0.setTitleColor(Palette.podaBlue.getColor(), for: .normal)
        $0.addTarget(self, action: #selector(goToNextPage), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPageControl()
        setupButtons()
    }
    
    private func setupScrollView() {
        let imageNames = ["onboarding0", "onboarding1", "onboarding2", "onboarding3", "onboarding4"]
        let numberOfPages = imageNames.count
        
        for (index, imageName) in imageNames.enumerated() {
            let imageView = UIImageView().then {
                $0.contentMode = .scaleAspectFill
                $0.image = UIImage(named: imageName)
                $0.frame = CGRect(x: view.frame.size.width * CGFloat(index), y: 0, width: view.frame.size.width, height: view.frame.size.height)
            }
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(numberOfPages), height: view.frame.size.height)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.centerX.equalToSuperview()
        }
        
        // UIPageControl 인디케이터 색상
        pageControl.pageIndicatorTintColor = Palette.podaBlue.getColor().withAlphaComponent(0.5) // 비활성화된 페이지 인디케이터 색상
        pageControl.currentPageIndicatorTintColor = Palette.podaBlue.getColor() // 현재 페이지 인디케이터 색상
    }
    
    
    private func setupButtons() {
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        skipButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalTo(pageControl.snp.centerY)
        }
        
        nextButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalTo(pageControl.snp.centerY)
        }
    }
    
    @objc func skipOnboarding() {
        UserDefaultManager.hasCompletedOnboarding = true

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainPage()
        }
    }
    
    @objc func goToNextPage() {
        let currentPage = pageControl.currentPage
        let nextPage = currentPage + 1
        let numberOfPages = pageControl.numberOfPages

        if nextPage < numberOfPages {
            let nextOffset = CGPoint(x: view.frame.width * CGFloat(nextPage), y: 0)
            scrollView.setContentOffset(nextOffset, animated: true)
        } else {
            // 온보딩 마지막 페이지일 때,
            skipOnboarding()
        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        // 마지막 페이지에 도달했을 때 버튼 타이틀 변경
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            nextButton.setTitle("시작", for: .normal)
        } else {
            nextButton.setTitle("다음", for: .normal)
        }
    }
    
    
}
