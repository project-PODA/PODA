//
//  LocationData.swift
//  PODA
//
//  Created by 랑 on 2/15/24.
//

import Foundation

struct LocationData: Decodable {
    let results: [Response]
}

struct Response: Decodable {
    let region: Region
}

// area1: 시/도, area2: 시/군/구, area3: 읍/면/동
struct Region: Decodable {
    let area1, area2, area3: Area
}

struct Area: Decodable {
    let name: String
}

