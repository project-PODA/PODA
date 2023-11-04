//
//  DiaryView.swift
//  PODA
//
//  Created by 배은서 on 11/3/23.
//

import UIKit

class DiaryView: UIView {
    var didTap: ((_ touchedLocation: CGPoint) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Palette.podaGray4.getColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedLocation = touch.location(in: self)
            didTap?(touchedLocation)
        }
    }
}
