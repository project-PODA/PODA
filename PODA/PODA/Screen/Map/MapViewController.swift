//
//  MapViewController.swift
//  PODA
//
//  Created by 랑 on 2/8/24.
//

// 성수역 37.544745, 127.055998
// 강남역 37.497973, 127.027614

import UIKit
import Then
import SnapKit
import NMapsMap
import CoreLocation

class MapViewController: UIViewController, NMFMapViewCameraDelegate {
    
    let photoBoothService = PhotoBoothService()
    let locationService = LocationService()
    let locationManager = CLLocationManager()
    var provinceName = ""
    var cityName = ""
    var townName = ""
    
    private let mapView = NMFMapView(frame: UIScreen.main.bounds)
    private lazy var photoBoothArray = ["인생네컷", "포토그레이", "포토이즘"]
    private lazy var photoBoothInfo: [Items] = []
    private var list1: [Items] {
        return photoBoothInfo.filter { $0.title.contains(photoBoothArray[0]) }
    }
    private var list2: [Items] {
        return photoBoothInfo.filter { $0.title.contains(photoBoothArray[1]) }
    }
    private var list3: [Items] {
        return photoBoothInfo.filter { $0.title.contains(photoBoothArray[2]) }
    }
    private lazy var markers: [NMFMarker] = []
    
    private lazy var locationButton = UIButton().then {
        $0.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        $0.tintColor = Palette.podaGray4.getColor()
        $0.addTarget(self, action: #selector(didTapLoacationButton), for: .touchUpInside)
    }
    
    private lazy var allButton = UIButton().then {
        $0.setUpButton(title: "전체", podaFont: .button1)
        $0.setTitleColor(Palette.podaGray4.getColor(), for: .normal)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapAllButton), for: .touchUpInside)
    }
    
    private lazy var button1 = UIButton().then {
        $0.setUpButton(title: photoBoothArray[0], podaFont: .button1)
        $0.setTitleColor(Palette.podaGray4.getColor(), for: .normal)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapButton1), for: .touchUpInside)
    }
    
    private lazy var button2 = UIButton().then {
        $0.setUpButton(title: photoBoothArray[1], podaFont: .button1)
        $0.setTitleColor(Palette.podaGray4.getColor(), for: .normal)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapButton2), for: .touchUpInside)
    }
    
    private lazy var button3 = UIButton().then {
        $0.setUpButton(title: photoBoothArray[2], podaFont: .button1)
        $0.setTitleColor(Palette.podaGray4.getColor(), for: .normal)
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 0.5
        $0.addTarget(self, action: #selector(didTapButton3), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocationManager()
        setMapView()
        configUI()
        
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setMapView() {
        // 실내지도 활성화
        mapView.isIndoorMapEnabled = true
        
        // 지하철 노선, 출구, 버스 정류장 등 대중교통 관련 요소 노출
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
        
    }
    
    func configUI() {
        [mapView, locationButton, allButton, button1, button2, button3].forEach {
            view.addSubview($0)
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(28)
        }
        
        allButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(locationButton.snp.right).offset(8)
            $0.width.equalTo(40)
            $0.height.equalTo(28)
        }
        
        button1.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(allButton.snp.right).offset(5)
            $0.width.equalTo(64)
            $0.height.equalTo(28)
        }
        
        button2.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(button1.snp.right).offset(5)
            $0.width.equalTo(80)
            $0.height.equalTo(28)
        }
        
        button3.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(button2.snp.right).offset(5)
            $0.width.equalTo(64)
            $0.height.equalTo(28)
        }
    }
    
    // 현 위치 근처의 포토부스 검색 데이터를 받아 리스트에 추가하는 함수
    func getPhotoBoothData() {
        for name in photoBoothArray {
            photoBoothService.fetchPhotoBooth(provinceName, townName, name) { searchResults in
                
                // print("검색 결과: \(searchResults)")
                
                // 검색 결과 title에 해당 포토부스 이름이 포함된 경우에만 리스트에 추가
                for i in 0...(searchResults.count - 1) {
                    
                    let result = searchResults[i]
                    let title = result.title
                    
                    if title.contains(name) {
                        self.photoBoothInfo.append(result)
                    }
                }
            }
        }
    }
    
    // 각 리스트를 마커로 표시하는 함수
    func setMarkers(_ photoBoothInfo: [Items]) {
        resetMarkers()
        
        var totalLat = 0.0
        var totalLng = 0.0
        
        for photoBooth in photoBoothInfo {
            let photoBoothLat = (Double(photoBooth.mapy) ?? 0) / 10000000
            let photoBoothLng = (Double(photoBooth.mapx) ?? 0) / 10000000
            
            totalLat += photoBoothLat
            totalLng += photoBoothLng
            
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: photoBoothLat, lng: photoBoothLng)
            marker.mapView = self.mapView
            
            // resetMarkers()를 위해 markers 배열에 추가
            self.markers.append(marker)
            
            let title = photoBooth.title
            marker.captionText = photoBooth.title.replacingOccurrences(of: "</b>", with: "").replacingOccurrences(of: "<b>", with: "")
            
            // FIX: - 마커 클릭 시 세부정보 모달창 올라오도록 하기
            let handler = { (overlay: NMFOverlay) -> Bool in
                if let marker = overlay as? NMFMarker {
                    
                }
                return true
            }
            
            marker.touchHandler = handler
        }
        
        let avgLat = totalLat / Double(photoBoothInfo.count)
        let avgLng = totalLng / Double(photoBoothInfo.count)
        
        // 카메라 위치를 모든 마커의 중간 지점으로 설정
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: avgLat, lng: avgLng))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func resetMarkers() {
        for marker in markers {
            marker.mapView = nil
        }
    }
    
    @objc func didTapLoacationButton() {
        self.photoBoothInfo = []
        locationManager.requestLocation()
    }
    
    @objc func didTapAllButton() {
        setMarkers(photoBoothInfo)
    }
    
    @objc func didTapButton1() {
        setMarkers(list1)
    }
    
    @objc func didTapButton2() {
        setMarkers(list2)
    }
    
    @objc func didTapButton3() {
        setMarkers(list3)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            // 현재 위경도로 동네이름 받아오는 함수 호출
            locationService.fetchLocation(latitude: lat, longitude: lng) { location in
                self.provinceName = location.provinceName
                self.cityName = location.cityName
                self.townName = location.townName
                
                self.getPhotoBoothData()
                
                DispatchQueue.main.async {
                    self.setMarkers(self.photoBoothInfo)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("위치 서비스 사용 가능")
            break
        case .restricted, .denied:
            print("위치 서비스 사용 불가")
            break
        case .notDetermined:
            print("권한 설정 필요")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            break
        default:
            break
        }
    }
    
}




