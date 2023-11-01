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
    
    // FIXME: - QR 테두리 cornerRadius 줘 말아.. 어차피 링크로 엄청 빠르게 연결돼서 안 보이긴 함
    private var qrCodeView = UIView().then {
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderWidth = 2
        //        $0.layer.cornerRadius = 5
        //        $0.clipsToBounds = true
    }
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 7
        $0.layer.shadowColor = Palette.podaBlack.getColor().cgColor
        $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCameraDevice()
        initCameraInputData()
        initCameraOutputData()
        displayPreview()
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
        let output = AVCaptureMetadataOutput()
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
            
            [self.backButton, self.qrCodeView].forEach {
                self.view.addSubview($0)
            }
            [self.backButton, self.qrCodeView].forEach {
                self.view.bringSubviewToFront($0)
            }
            
            self.backButton.snp.makeConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
                $0.left.equalToSuperview().offset(20)
                $0.width.height.equalTo(30)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    @objc func didTapBackButton() {
        dismiss(animated: true)
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            self.qrCodeView.transform = CGAffineTransform(scaleX: 0, y: 0)
            return
        }
        
        guard let metaDataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            print("Fail to cast MetaData as AVMetadataMachineReadableCodeObject")
            return
        }
        
        if metaDataObj.type == .qr {
            guard let qrCodeObject = videoPreviewLayer.transformedMetadataObject(for: metaDataObj) else { return }
            DispatchQueue.main.async {
                self.qrCodeView.frame = qrCodeObject.bounds
                UIView.animate(withDuration: 0.5) {
                    self.qrCodeView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            
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
