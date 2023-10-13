//
//  MainViewModel.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//
import Foundation

class MainViewModel {

    //이 방식은 자제해주세요.
    //    init() {
    //    self.networkManager = NetworkManager()
    //    }
    // 혹은
    // var networkManager = NetworkManager()
    
    init(networkManager : NetworkManager){
        self.networkManager = networkManager
    }
    
    private let networkManager: NetworkManager!
    var labelText = Observable<String>("")
    var postData = Observable<Post?>(nil)
//  var postDataArray = Observable<[Post]>([]) 배열의 경우 이렇게 등록해서 사용하시면 됩니다.
 
    func setText(text : String){
        labelText.value = text
    }
    func fetchTestData(apiUrl: String) {
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        networkManager.fetchData(from: url) { [weak self ](result: Result<Post, NetworkError>) in
            guard let self = self else {return}
            switch result {
            case .success(let post):
                postData.value = post
            case .failure(let error):
                print(error)
            }
        }
    }
    func clearText(){
        labelText.value = ""
    }
}

struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

