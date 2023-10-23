//
//  ColorPaletteView.swift
//  PODA
//
//  Created by 배은서 on 2023/10/20.
//

import UIKit
import SnapKit
import Then

struct Font {
    let text: String
    let font: UIFont
}

class ColorPaletteView: UIView {
    
    // MARK: - Properties
    private let fontList: [Font] = [
        Font(text: "프리텐다드", font: UIFont(name: "Pretendard-Regular", size: 17) ?? UIFont()),
        Font(text: "도스샘물", font: UIFont(name: "DOSSaemmul", size: 17) ?? UIFont()),
        Font(text: "나눔명조", font: UIFont(name: "NanumMyeongjoOTF", size: 17) ?? UIFont()),
        Font(text: "바른히피", font: UIFont(name: "NanumBaReunHiPi", size: 20) ?? UIFont()),
        Font(text: "나눔스퀘어라운드", font: UIFont(name: "NanumSquareRoundB", size: 17) ?? UIFont()),
        Font(text: "써라운드", font: UIFont(name: "Cafe24SsurroundOTF", size: 17) ?? UIFont()),
        Font(text: "고운돋움", font: UIFont(name: "GowunDodum-Regular", size: 17) ?? UIFont())
    ]
    private var colorList: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .cyan, .magenta]
    
    private let customColorButton = UIColorWell()
    
    private let fontFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 25
    }
    
    private let colorFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 5
    }
    
    private lazy var fontCollectionView = UICollectionView(frame: .zero, collectionViewLayout: fontFlowLayout)
    
    private lazy var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorFlowLayout)
    
    private let colorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - InitUI
    
    private func configUI() {
        backgroundColor = .black
        setupLayout()
        setupCollectionView()
    }
    
    private func setupLayout() {
        [customColorButton, colorCollectionView].forEach {
            colorStackView.addArrangedSubview($0)
        }
        
        [fontCollectionView, colorStackView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        customColorButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func setupCollectionView() {
        [fontCollectionView, colorCollectionView].forEach {
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
        }
        
        fontCollectionView.register(FontCollectionViewCell.nib(), forCellWithReuseIdentifier: FontCollectionViewCell.identifier)
        colorCollectionView.register(ColorCollectionViewCell.nib(), forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
    }
    
    // MARK: - Custom Method
    
    func isHiddenFont(_ isHidden: Bool) {
        fontCollectionView.isHidden = isHidden
    }
    
}

//MARK: - UICollectionViewDataSource

extension ColorPaletteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == fontCollectionView {
            return fontList.count
        } else {
            return colorList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == fontCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontCollectionViewCell.identifier, for: indexPath) as? FontCollectionViewCell
            else { return UICollectionViewCell() }
            
            cell.setFontLabel(fontList[indexPath.item])
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell
            else { return UICollectionViewCell() }
            
            cell.layer.cornerRadius = 18.5
            cell.setColor(colorList[indexPath.item])
            
            return cell
        }
    }
}

extension ColorPaletteView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == fontCollectionView {
            let label = UILabel()
            label.text = fontList[indexPath.item].text
            label.font = fontList[indexPath.item].font
            label.sizeToFit()
            return CGSize(width: label.frame.width, height: 20)
        } else {
            return CGSize(width: 37, height: 37)
        }
    }
}

//MARK: - UICollectionViewDelegate

extension ColorPaletteView: UICollectionViewDelegate {
    
}
