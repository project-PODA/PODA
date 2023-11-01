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
    
    var touchedColor: ((_ color: UIColor) -> ())?
    var changedCustomColor: ((_ color: UIColor) -> ())?
    var touchedCustomColorButton: ((_ colorPicker: UIColorPickerViewController) -> ())?
    var finishedCustomColor: (() -> ())?
    
    var touchedFont: ((_ font: UIFont) -> ())?
    
    private let fontList: [Font] = [
        Font(text: "프리텐다드", font: UIFont(name: "Pretendard-Regular", size: 17) ?? UIFont()),
        Font(text: "도스샘물", font: UIFont(name: "DOSSaemmul", size: 17) ?? UIFont()),
        Font(text: "나눔명조", font: UIFont(name: "NanumMyeongjoOTF", size: 17) ?? UIFont()),
        Font(text: "바른히피", font: UIFont(name: "NanumBaReunHiPi", size: 20) ?? UIFont()),
        Font(text: "나눔스퀘어라운드", font: UIFont(name: "NanumSquareRoundB", size: 17) ?? UIFont()),
        Font(text: "써라운드", font: UIFont(name: "Cafe24SsurroundOTF", size: 17) ?? UIFont()),
        Font(text: "고운돋움", font: UIFont(name: "GowunDodum-Regular", size: 17) ?? UIFont())
    ]
    private var colorList: [UIColor] = [
        .white,
        UIColor(red: 0.796, green: 0.796, blue: 0.796, alpha: 1),
        UIColor(red: 0.521, green: 0.521, blue: 0.521, alpha: 1),
        UIColor(red: 0.221, green: 0.221, blue: 0.221, alpha: 1),
        .black,
        UIColor(red: 0.983, green: 0.836, blue: 0.836, alpha: 1),
        UIColor(red: 0.984, green: 0.952, blue: 0.835, alpha: 1),
        UIColor(red: 0.874, green: 0.984, blue: 0.835, alpha: 1),
        UIColor(red: 0.835, green: 0.984, blue: 0.975, alpha: 1),
        UIColor(red: 0.984, green: 0.835, blue: 0.969, alpha: 1),
        UIColor(red: 0.788, green: 0.276, blue: 0.276, alpha: 1),
        UIColor(red: 0.788, green: 0.552, blue: 0.276, alpha: 1),
        UIColor(red: 0.501, green: 0.788, blue: 0.276, alpha: 1),
        UIColor(red: 0.276, green: 0.388, blue: 0.788, alpha: 1),
        UIColor(red: 0.788, green: 0.276, blue: 0.644, alpha: 1)
    ]
    
    private lazy var colorPicker = UIColorPickerViewController().then {
        $0.delegate = self
    }
    
    private lazy var customColorButton = UIButton().then {
        $0.frame.size = CGSize(width: 37, height: 37)
        $0.setImage(UIImage(named: "icon_colorPicker"), for: .normal)
        $0.addTarget(self, action: #selector(touchUpCustomColorButton), for: .touchUpInside)
    }
    
    private let fontFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 25
    }
    
    private let colorFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 5
    }
    
    private lazy var fontCollectionView = UICollectionView(frame: .zero, collectionViewLayout: fontFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let colorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
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
        
        addSubview(stackView)
        
        colorCollectionView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        customColorButton.snp.makeConstraints {
            $0.width.height.equalTo(38)
        }
        
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
    
    //MARK: - @objc
    
    @objc private func touchUpCustomColorButton() {
        touchedCustomColorButton?(colorPicker)
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
        
            cell.setColor(colorList[indexPath.item])
            
            if cell.colorView.backgroundColor == .black {
                cell.colorView.layer.borderWidth = 1
                cell.colorView.layer.borderColor = UIColor.white.cgColor
            }
            
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            touchedColor?(colorList[indexPath.item])
        } else {
            touchedFont?(fontList[indexPath.item].font)
        }
    }
}

extension ColorPaletteView: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        changedCustomColor?(color)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        finishedCustomColor?()
    }
}
