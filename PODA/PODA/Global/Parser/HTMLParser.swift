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
                    <table width="648" cellspacing="0" cellpadding="0" border="0" align="left" style="background-color: #619AEE; width: 648px; height: 180px;">
                        <tr>
                            <td align="center" valign="middle" style="color: white; font-size: 25px; height: 180px;">
                                PODA 이메일 인증코드 안내
                            </td>
                        </tr>
                    </table>
                    <br><br><br><br><br><br><br><br><br><br><br><br>
                    <div>안녕하세요</div>
                    <div>\(email) 고객님,</div>
                    <div>포토부스 조각 사진 저장 어플리케이션 'PODA' 회원가입 진행을 환영합니다.</div>
                    <div>아래 인증번호를 입력하여 이메일 인증을 완료해 주세요.</div>
                    <br>
                    <br>
                    <div style="width: 648px; border-top: 1px solid black;"></div>
                    <div style="display: block; margin-top: 10px;"></div>
                    <div style='font-size: 30px; font-weight: bold; color: black; display: inline;'>인증번호: <span style="color: #619AEE">\(authCode)</span></div>
                    <div style="width: 648px; border-top: 1px solid black;"></div>
                    <br>
                    <br><br>
                    <div>문의 poda_official@naver.com</div>
                    <div style='font-size: 12px; color: grey;'>Copyright ⓒ PODA All Rights Reserved.</div>
                </body>
            </html>
            """
        
        return htmlContent
    }
}
