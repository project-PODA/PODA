//
//  LeaveViewModel.swift
//  PODA
//
//  Created by FUTURE on 11/7/23.
//

import UIKit
import NVActivityIndicatorView

class LeaveViewModel {
    
    private let fireAuthManager: FireAuthManager
    
    var onAccountDeletionSuccess: (() -> Void)?
    var onAccountDeletionFailure: ((String) -> Void)?
    
    init(fireAuthManager: FireAuthManager) {
        self.fireAuthManager = fireAuthManager
    }
    
    func deleteAccount(withConfirmation text: String) {
        guard text == "동의합니다" else {
            onAccountDeletionFailure?("\"동의합니다\"를 입력해주세요")
            return
        }
        
        RealmManager.shared.deleteLocalUserData()

        fireAuthManager.deleteAccount { error in
            if error == .none {
                self.onAccountDeletionSuccess?()
            } else {
                self.onAccountDeletionFailure?("탈퇴에 문제가 발생했습니다. 고객센터에 연락해주세요.")
            }
        }
    }
}

