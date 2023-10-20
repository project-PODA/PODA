//
//  CreateDiaryViewController.swift
//  PODA
//
//  Created by 배은서 on 2023/10/19.
//

import UIKit
import SnapKit
import Then

class CreateDiaryViewController: BaseViewController, ViewModelBindable, UIConfigurable {
    
    // MARK: - Properties
    
    var viewModel: CreateDiaryViewModel!
    var ratio: Ratio!
    
    private lazy var cancelButton = UIButton().then {
        $0.setUpButton(title: "취소", podaFont: .subhead2)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
    }
    
    private lazy var nextButton = UIButton().then {
        $0.setUpButton(title: "다음", podaFont: .subhead2)
        $0.tintColor = Palette.podaWhite.getColor()
        $0.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Palette.podaBlack.getColor()
    }
    
    private let diaryView = UIView().then {
        $0.backgroundColor = Palette.podaGray4.getColor()
    }
    
    private let pageLabel = UILabel().then {
        $0.setUpLabel(title: "페이지 목록", podaFont: .subhead2)
        $0.textColor = Palette.podaWhite.getColor()
    }
    
    private lazy var pageAddButton = UIButton().then {
        $0.setImage($0.resizeImageButton(image: UIImage(systemName: "plus"), width: 48, height: 48, color: Palette.podaWhite.getColor()), for: .normal)
        $0.backgroundColor = Palette.podaGray4.getColor()
        $0.layer.cornerRadius = 5
        $0.addTarget(self, action: #selector(touchUpAddPageButton), for: .touchUpInside)
    }
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 11
        $0.itemSize = CGSize(width: 121, height: 121)
    }
    
    private lazy var pageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var backgroundButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "배경", iconName: "icon_background")
        $0.addTarget(self, action: #selector(touchUpBackgroundButton), for: .touchUpInside)
    }
    private var isSelectedBackgroundButton = false
    
    private lazy var galleryButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "사진", iconName: "icon_gallery")
        $0.addTarget(self, action: #selector(touchUpGalleryButton), for: .touchUpInside)
    }
    
    private lazy var stickerButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "스티커", iconName: "icon_sticker")
        $0.addTarget(self, action: #selector(touchUpStickerButton), for: .touchUpInside)
    }
    
    private lazy var textButton = UIButton().then {
        $0.configuration = getButtonConfiguration(title: "글 추가", iconName: "icon_text")
        $0.addTarget(self, action: #selector(touchUpTextButton), for: .touchUpInside)
    }
    
    private let decorateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 30
    }
    
    private lazy var decorateView = UIView().then {
        $0.backgroundColor = Palette.podaBlack.getColor()
        $0.addSubview(decorateStackView)
    }
    
    private let selectBackgroundColorView = ColorPaletteView().then {
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    init(viewModel: CreateDiaryViewModel, ratio: Ratio) {
        self.viewModel = viewModel
        self.ratio = ratio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    func configUI() {
        setupLayout()
        setCollectionView()
    }
    
    private func setupLayout() {
        [backgroundButton, galleryButton, stickerButton, textButton].forEach {
            decorateStackView.addArrangedSubview($0)
        }
        
        [diaryView, pageLabel, pageAddButton, pageCollectionView].forEach {
            scrollView.addSubview($0)
        }
        
        [cancelButton, nextButton,
         scrollView,
         decorateView,
         selectBackgroundColorView].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(nextButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateView.snp.top)
        }
        
        diaryView.snp.makeConstraints {
            $0.top.equalTo(scrollView)
            $0.leading.trailing.equalToSuperview()
            
            switch ratio {
            case .square:
                $0.width.height.equalTo(393)
            case .rectangle:
                $0.width.equalTo(393)
                $0.height.equalTo(524)
            case .none:
                $0.width.height.equalTo(393)
            }
        }
        
        pageLabel.snp.makeConstraints {
            $0.top.equalTo(diaryView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(26)
        }
        
        pageAddButton.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.width.height.equalTo(106)
        }
        
        pageCollectionView.snp.makeConstraints {
            $0.top.equalTo(pageAddButton.snp.top).offset(-15)
            $0.leading.equalTo(pageAddButton.snp.trailing).offset(11)
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(121)
        }
        
        decorateView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        decorateStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(decorateView).inset(40)
            $0.bottom.equalTo(decorateView).inset(18)
        }
        
        selectBackgroundColorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(decorateStackView.snp.top)
            $0.height.equalTo(67)
        }
    }
    
    //MARK: - @objc
    
    @objc private func touchUpCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func touchUpNextButton() {
        let viewController = DetailDiaryViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func touchUpAddPageButton() {
        
    }
    
    @objc private func touchUpBackgroundButton() {
        UIView.animate(withDuration: 0.8) {
            self.selectBackgroundColorView.isHidden = self.isSelectedBackgroundButton
        }
        isSelectedBackgroundButton.toggle()
    }
    
    @objc private func touchUpGalleryButton() {
        
    }
    
    @objc private func touchUpStickerButton() {
        
    }
    
    @objc private func touchUpTextButton() {
        
    }
    
    // MARK: - Custom Method
    
    func bindViewModel() {
        
    }
    
    func setCollectionView() {
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.register(PageCollectionViewCell.nib(), forCellWithReuseIdentifier: PageCollectionViewCell.identifier)
        pageCollectionView.backgroundColor = .clear
    }
    
    func getButtonConfiguration(title: String, iconName: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString.init(title)
        titleAttr.foregroundColor = Palette.podaWhite.getColor()
        titleAttr.font = UIFont.podaFont(.subhead1)
        config.attributedTitle = titleAttr
        config.image = UIImage(named: iconName)
        config.imagePlacement = .top
        config.imagePadding = 10
        
        return config
    }

}

//MARK: - UICollectionViewDataSource

extension CreateDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = pageCollectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.identifier, for: indexPath) as? PageCollectionViewCell
        else { return UICollectionViewCell() }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension CreateDiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
