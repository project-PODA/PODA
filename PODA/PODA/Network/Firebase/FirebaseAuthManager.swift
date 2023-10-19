//
//  FirebaseAuthManager.swift
//  PODA
//
//  Created by 박유경 on 2023/10/18.
//

import FirebaseAuth

class FireAuthManager {
    //테스트용으로 함수 하나 만들어서 사용.
    func userLogin(){
        Auth.auth().signIn(withEmail: "test@naver.com", password: "dbrudzzang") { authResult, error in
            if let error = error {
                print("로그인 실패:", error)
            } else {
                print("로그인 성공:", authResult?.user.uid ?? "")
            }
        }
    }
}
