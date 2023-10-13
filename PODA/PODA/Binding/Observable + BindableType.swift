//
//  Observable + BindableType.swift
//  temp
//
//  Created by 박유경 on 2023/10/09.
//

import UIKit
class Observable<T> {
    typealias Observer = (T) -> Void
    var observers: [Observer] = []
    
    init(_ value: T) {
        self.value = value
    }
    func addObserver(_ observer: @escaping Observer) {
        observers.append(observer)
        observer(value)
    }
    func notifyObservers() {
        for observer in observers {
            observer(value)
        }
    }
    var value: T {
        didSet {
            notifyObservers()
        }
    }
}

protocol ViewModelBindable: AnyObject {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}
extension ViewModelBindable where Self: UIViewController {
    func bind(to model: Self.ViewModelType) {
        self.viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
