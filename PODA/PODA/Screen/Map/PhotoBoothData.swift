//
//  PhotoBoothData.swift
//  PODA
//
//  Created by 랑 on 2/8/24.
//

import Foundation

struct PhotoBoothData: Decodable {
    let items: [Items]
}

struct Items: Decodable {
    let title: String
    let address: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}
