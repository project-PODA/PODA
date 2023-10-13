//
//  NetworkProtocol + NetworkError.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData
}

protocol NetworkManagerProtocol : AnyObject{
   func fetchData<T: Decodable>(from url: URL, completion: @escaping (Result<T, NetworkError>) -> Void)//차후에 T : Decodable 세분화.
}

