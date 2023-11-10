//
//  NoticeViewModel.swift
//  PODA
//
//  Created by FUTURE on 11/10/23.
//

import UIKit

class NoticeViewModel {
    
    private let fireDBManager: FirestorageDBManager
    
    init(fireDBManager: FirestorageDBManager) {
        self.fireDBManager = fireDBManager
    }
    
    var notices: [NoticeInfo] = [] {
        didSet {
            self.onNoticesChanged?()
        }
    }
    
    var onNoticesChanged: (() -> Void)?
    
    // 공지사항 내용 셀 높이 측정
    func estimateHeightForContent(content: String, width: CGFloat) -> CGFloat {
        let approximateWidthOfContent = width - 40
        let size = CGSize(width: approximateWidthOfContent, height: .greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    func getNotices() {
        fireDBManager.getNotices { [weak self] notices, error in
            guard let self = self else { return }
            
            if error == .none && !notices.isEmpty {
                // 에러가 있는 경우 처리
                self.notices = notices
                print("Successfully loaded \(notices.count) notices")
            } else if !notices.isEmpty {
                // 에러가 없고, notices가 비어있지 않은 경우
                print("Error loading notices: \(error)")
                
            }
        }
    }
    
    func formattedDate(_ date: String) -> String {
        return Date.updateTime(dateTime: date)
    }
    
    func toggleContentVisibility(at index: Int) {
        guard notices.indices.contains(index) else { return }
        notices[index].isContentVisible.toggle()
        onNoticesChanged?()
    }

}
