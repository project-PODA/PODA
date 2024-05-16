//
//  LocationService.swift
//  PODA
//
//  Created by Rang Lee on 5/14/24.
//

import Foundation
import CoreLocation

struct LocationService {
    
    let locationURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?output=json"
    
    func fetchLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (_ location: LocationModel) -> ()) {
        let coords = "\(longitude),\(latitude)"
        let urlString = "\(locationURL)&coords=\(coords)"
        if let url = URL(string: urlString) {
            var requestURL = URLRequest(url: url)
            requestURL.addValue(ClientKey.mapID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
            requestURL.addValue(ClientKey.mapSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: requestURL) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let location = parseJson(with: safeData) {
                        print(location)
                        completion(location)
                    }
                }
            }
            
            task.resume()
        }
        
    }
    
    func parseJson(with data: Data) -> LocationModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(LocationData.self, from: data)
            let province = decodedData.results[0].region.area1.name
            let city = decodedData.results[0].region.area2.name
            let town = decodedData.results[0].region.area3.name
            
            let location = LocationModel(provinceName: province, cityName: city, townName: town)
            return location
            
        } catch {
            print(error)
            return nil
        }
    }
}
