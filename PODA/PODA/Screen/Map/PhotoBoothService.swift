//
//  PhotoBoothService.swift
//  PODA
//
//  Created by Rang Lee on 5/13/24.
//

import Foundation

struct PhotoBoothService {
    
    let MapURL = "https://openapi.naver.com/v1/search/local.json?display=5"
    
    func fetchPhotoBooth(_ province: String, _ town: String, _ query: String, completion: @escaping (_ items: [Items]) -> ()) {
        let urlString = "\(MapURL)&query=\(province) \(town) \(query)"
        print(urlString)
        
        if let url = URL(string: urlString) {
            var requestURL = URLRequest(url: url)
            requestURL.addValue(ClientKey.searchID, forHTTPHeaderField: "X-Naver-Client-Id")
            requestURL.addValue(ClientKey.searchSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: requestURL) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safedata = data {
                    if let photoBoothList = parseJson(with: safedata) {
                        completion(photoBoothList)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJson(with data: Data) -> [Items]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PhotoBoothData.self, from: data)
            return decodedData.items
        } catch {
            print(error)
            return nil
        }
    }
}

