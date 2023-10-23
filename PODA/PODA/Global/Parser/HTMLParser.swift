//
//  HTMLParser.swift
//  PODA
//
//  Created by 박유경 on 2023/10/23.
//



//나중에 태그별로 각 의미에 맞게 분리할것.
struct HTMLParser {
    
    func getSMTPSampleString(email: String, authCode : Int, base64Image : String) -> String {
        let htmlContent =
            """
            <html>
                <body>
                    <img src="data:image/png;base64,\(base64Image)" width="200" height="150">
                    <br><br><br><br>
                    <div>안녕하세요 \(email) 고객님,</div>
                    <div>오프라인 포토부스 사전 다이어리 서비스 'PODA' 회원가입 진행을 환영합니다.</div>
                    <br>
                    <div>아래 인증번호를 입력하여 이메일 인증을 완료해 주새요.</div>
                    <hr style="border: none; border-top: 1px solid black;">
                    <div style="display: block; margin-top: 10px;"></div>
                    <div style='font-size: 24px; font-weight: bold; color: black; display: inline;'>인증번호: <span style="color: blue;">\(authCode)</span></div>
                    <hr style="border: none; border-top: 1px solid black;">
                    <br>
                    <br><br>
                    <div>문의: poda_official@naver.com</div>
                    <div style='font-size: 18px; font-weight: bold; color: grey;'>Copyright ⓒ PODA All Rights Reserved.</div>
                </body>
            </html>
            """
    
        return htmlContent
    }
}
