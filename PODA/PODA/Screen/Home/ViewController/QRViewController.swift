//
//  QRViewController.swift
//  PODA
//
//  Created by 랑 on 2023/11/01.
//

import UIKit
import AVFoundation

class QRViewController: BaseViewController, UIConfigurable {

    private var captureSession = AVCaptureSession()
    private var cameraDevice: AVCaptureDevice?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let qrCodeView = UIView().then {
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        initCameraDevice()
        initCameraInputData()
        initCameraOutputData()
        displayPreview()
        initQRCodeFrameView()
    }

    private func initQRCodeFrameView() {
        view.addSubview(qrCodeView)
        view.bringSubviewToFront(qrCodeView)
    }
    
    private func initCameraDevice() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        cameraDevice = captureDevice
    }
    
    private func initCameraInputData() {
        if let cameraDevice = self.cameraDevice {
            do {
                let input = try AVCaptureDeviceInput(device: cameraDevice)
                if captureSession.canAddInput(input) { captureSession.addInput(input) }
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func initCameraOutputData() {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(captureMetadataOutput) { captureSession.addOutput(captureMetadataOutput) }
            
        // Output 데이터가 들어왔을 때, 처리할 Delegate 설정
        // Camera로 들어오는 데이터 타입이 QR코드 임을 명시
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
    
    private func displayPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async {
            self.videoPreviewLayer?.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer!)
        }
            
        // startRunning을 실행시켜야 화면이 보이게 됩니다.
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    // MetaData가 들어올 때마다 실행되는 메소드
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            self.qrCodeView.transform = CGAffineTransform(scaleX: 0, y: 0)
            return
        }
    
        // MetaData을 사람이 읽을 수 있는 Data로 캐스팅
        guard let metaDataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            print("Fail to cast MetaData as AVMetadataMachineReadableCodeObject")
            return
        }
    
        // QR 데이터인 경우
        if metaDataObj.type == .qr {
            // MetaData을 캡쳐한 직접적인 화면을 가져온다.
            let qrCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metaDataObj)
            // 가져온 QR Code 화면을 캡쳐한 위치를 넣어준다.
            self.qrCodeView.frame = qrCodeObject!.bounds
            // 작은 곳에서 커지게 애니메이션
            UIView.animate(withDuration: 0.5) {
                self.qrCodeView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
      
            // 여기서 직접적으로 가져온 QR Code 데이터를 해독한다.
            guard let qrCodeStringData = metaDataObj.stringValue else { return }
            
            print(qrCodeStringData)
        }
    }
}
