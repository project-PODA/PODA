
json형태 : diaryInfo  
{
  "updateTime": "",
  "deviceName": "iPad Pro (12.9-inch) (6th generation)",
  "frameRate": "OneToOne",
  "diaryTitle": "제목3",
  "diaryDetail": {
    "pageInfo": [
      {
        "componentInfo": {
          "image": [],
          "sticker": [],
          "label": []
        },
        "backgroundColor": "#AA00EE",
        "page": 1
      },
      {
        "componentInfo": {
          "image": [],
          "sticker": [],
          "label": []
        },
        "backgroundColor": "#EEAA33",
        "page": 2
      }
    ],
    "totalPage": 2
  },
  "description": "내용임2",
  "diaryName": "제목3",
  "createTime": "2023-10-18 21:26:25"
}




예제
//1) 사용자가 갖고 있는 다이어리 목록 리스트를 얻고 모든 다이어리에 json으로 저장된 정보를 가져온다.
 firebaseManager.getDiaryDocuments { [weak self] (documentNames, error) in
     guard let self = self else {return}
     
     if error != .none {
         print("Error occurred")
     } else {
         if !documentNames.isEmpty {
             
             firebaseManager.getDiaryData(diaryNameList: documentNames) { diaryInfoList, error in
                 if error != .none {
                     print("Error occurred")
                 } else {
                     for diaryInfo in diaryInfoList {
                         for pageInfo in diaryInfo.diaryDetail.pageInfo
                         {
                             self.view.backgroundColor = UIColor.fromHexString(pageInfo.backgroundColor)
                         }
                     }
                 }
             }
         }
         else {
             print("No documents found.")
         }
     }
 }
 
//2) 다이어리의 각 페이지에 해당하는 최종 이미지와 이름, 생성일, 내용을 저장하고 최종이미지를 저장하는 예제(title 이름기준으로 새로 생성) 
 let image1 = UIImage(named: "logo_poda")
 let image2 = UIImage(named: "logo_poda")
 let imageList = [image1!.pngData()!, image2!.jpegData(compressionQuality: 0.5)!]
 let title = "제목8"
 let pageDataList = [
     PageInfo(
         page: 1,
         backgroundColor: Palette.podaBlack.getColor().toHexString(),
         componentInfo: ComponentInfo(
             image: [],
             sticker: [],
             label: []
         )
     ),
     PageInfo(
         page: 2,
         backgroundColor: Palette.podaRed.getColor().toHexString(),
         componentInfo: ComponentInfo(
             image: [],
             sticker: [],
             label: []
         )
     )
 ]
 firebaseManager.createDiary(deviceName: UIDevice.current.name,pageDataList : pageDataList,title: title, description: "내용임2", frameRate: .OneToOne, backgroundColor: "#FF00FF"){ [weak self] error in
     guard let self = self else{return}
     if error == .none {
         print("다이어리 데이터 저장 성공")
         firebaseStorageManager.createDiaryImage(diaryName: title, pageImageList: imageList){ error in
             if error == .none{
                 print("다이어리 이미지 저장 성공")
             }else{
                 print("다이어리 이미지 저장 중 에러 발생")
             }
         }
     }else{
         print("다이어리 데이터 저장 중 에러 발생")
     }
 }
 
 
//3) 다이어리 이름을 기준으로 데이터 및 이미지 삭제 
  let targetDiaryName = "제목5" // 혹은 getDiaryDocuments를 통해 얻은 다이어리를 목록을 통해 지우고자 하는 단일 다이어리 이름을 지정
  firebaseManager.deleteDiary(diaryName: targetDiaryName){ [weak self] error in
      guard let self = self else {return}
      if error == .none{
          print("다이어리 삭제 성공")
          firebaseStorageManager.deleteDiaryImage(diaryName: targetDiaryName) { [weak self] error in
              if error == .none {
                print("다이어리 이미지 삭제 성공")
              }else {
                  print("다이어리 이미지 삭제 실패")
              }
          }
      } else {
          print("다이어리 삭제 실패")
      }
  }
  
//3) 다이어리 이미지만 삭제(프로필이 없다면 폴더까지 삭제가 됨 모르면 문의) 
   firebaseManager.getDiaryDocuments { [weak self] (diaryList, error) in
     guard let self = self else {return}

     if !diaryList.isEmpty {
         for diary in diaryList{
             firebaseStorageManager.deleteDiaryImage(diaryName: diary) { error in
                 if error == .none {
                     print("다이어리 이미지 삭제 성공")
                 } else {
                     print("다이어리 이미지 삭제 실패")
                 }
             }
         }

     } else {
         print("다이어리 리스트가 비어 있음.")
     }
 }
