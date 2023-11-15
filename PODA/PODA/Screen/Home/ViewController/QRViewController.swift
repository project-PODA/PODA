//
//  QRViewController.swift
//  PODA
//
//  Created by 랑 on 2023/11/01.
//

import UIKit
import Then
import SnapKit
import AVFoundation

class QRViewController: BaseViewController {
    
    private var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private var captureSession = AVCaptureSession()
    private var cameraDevice: AVCaptureDevice?
    // output = AVCaptureMetadataOutput() > 이렇게 하면, 탭바가 실행되면서 QRViewController도 같이 실행되는데 이 때 AVCaptureMetadataOutput()가 생성되면서 아래 오류가 생김
    // Thread 1: "*** -[AVCaptureMetadataOutput setMetadataObjectTypes:] Unsupported type found (org.iso.QRCode) - use -availableMetadataObjectTypes"
    // 따라서 생성하지 말고 아래처럼 타입 선언까지만 해주기
    private var output: AVCaptureMetadataOutput?

    
    // FIXME: - QR 테두리 cornerRadius 줘 말아.. 어차피 링크로 엄청 빠르게 연결돼서 안 보이긴 함
    private var qrBorderView = UIView().then {
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 2
        //        $0.layer.cornerRadius = 5
        //        $0.clipsToBounds = true
    }
    
    lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 7
        $0.layer.shadowColor = Palette.podaBlack.getColor().cgColor
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    private var infoLabel = UILabel().then {
        $0.setUpLabel(title: "QR코드를 스캔해주세요", podaFont: .subhead3)
        $0.textColor = Palette.podaWhite.getColor()
        $0.addShadowToLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCameraDevice()
        initCameraInputData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CameraAccessHelper.requestCameraAccess(presenter: self) { [weak self] isAuthorized in
            DispatchQueue.main.async {
                if isAuthorized {
                    guard let self else { return }
                    self.initCameraOutputData()
                    self.displayPreview()
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.captureSession.startRunning()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
        removeCameraOutputData()
    }
    
    private func initCameraDevice() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        cameraDevice = captureDevice
    }
    
    private func initCameraInputData() {
        if let cameraDevice = self.cameraDevice {
            do {
                let input = try AVCaptureDeviceInput(device: cameraDevice)
                captureSession.addInput(input)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func initCameraOutputData() {
        output = AVCaptureMetadataOutput()
        
        guard let output = output else { return }
        captureSession.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
    
    private func displayPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer)
            
            [self.backButton, self.infoLabel, self.qrBorderView].forEach {
                self.view.addSubview($0)
            }
            [self.backButton, self.infoLabel, self.qrBorderView].forEach {
                self.view.bringSubviewToFront($0)
            }
            
            self.backButton.snp.makeConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
                $0.left.equalToSuperview().offset(20)
                $0.width.height.equalTo(30)
            }
            
            self.infoLabel.snp.makeConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(6)
                $0.centerX.equalToSuperview()
            }
        }
    }
    
    private func removeCameraOutputData() {
        guard let output = output else { return }
        captureSession.removeOutput(output)
    }
    
    @objc func didTapBackButton() {
        dismiss(animated: true)
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            self.qrBorderView.transform = CGAffineTransform(scaleX: 0, y: 0)
            return
        }
        
        guard let metaDataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            print("Fail to cast MetaData as AVMetadataMachineReadableCodeObject")
            return
        }
        
        if metaDataObj.type == .qr {
            guard let qrCodeObject = videoPreviewLayer.transformedMetadataObject(for: metaDataObj) else { return }
            DispatchQueue.main.async {
                self.qrBorderView.frame = qrCodeObject.bounds
                UIView.animate(withDuration: 0.5) {
                    self.qrBorderView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            
            // FIXME: - http:// 링크 이동 안되면 추가 처리하기
            guard let qrCodeStringData = metaDataObj.stringValue else { return }
            if qrCodeStringData.hasPrefix("http://") || qrCodeStringData.hasPrefix("https://") {
                if let url = URL(string: qrCodeStringData) {
                    UIApplication.shared.open(url, options: [:])
                    dismiss(animated: true)
                }
            }
        }
    }
}
