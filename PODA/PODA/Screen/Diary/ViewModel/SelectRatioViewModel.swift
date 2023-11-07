//
//  SelectRatioViewModel.swift
//  PODA
//
//  Created by 배은서 on 11/6/23.
//

import Foundation
import UIKit

class SelectRatioViewModel {
    
    var ratio: Observable<Ratio?> = Observable(nil)
    
    func handleSquareButton() {
        ratio.value = .square
    }
    
    func handleRectangleButton() {
        ratio.value = .rectangle
    }
    
    func getRatio() -> Ratio? {
        return ratio.value
    }
    
//    func handleNextButton(fromCurrentViewController: UIViewController, alertViewController: UIAlertController) {
//        if let ratio = ratio.value {
//            let viewController = CreateDiaryViewController(viewModel: CreateDiaryViewModel(), ratio: ratio)
//            fromCurrentViewController.navigationController?.pushViewController(viewController, animated: true)
//        } else {
//            fromCurrentViewController.present(alertViewController, animated: true)
//        }
//    }
}
