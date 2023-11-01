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

//Thread 1: "*** -[AVCaptureMetadataOutput setMetadataObjectTypes:] Unsupported type found (org.iso.QRCode) - use -availableMetadataObjectTypes"

class QRViewController: BaseViewController, UIConfigurable {

    private var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private var captureSession = AVCaptureSession()
    private var cameraDevice: AVCaptureDevice?
    
    private let qrCodeView = UIView().then {
        $0.layer.borderColor = Palette.podaBlue.getColor().cgColor
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
    }
    
    private lazy var UrlTextView = UITextView().then {
        $0.font = UIFont.podaFont(.caption)
        $0.textColor = Palette.podaWhite.getColor()
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.dataDetectorTypes = .link
        $0.textAlignment = .center
        $0.delegate = self
    }
    
    private let UrlLabel = UILabel().then {
        $0.textColor = .black
        $0.backgroundColor = Palette.podaBlue.getColor()
        $0.font = UIFont.systemFont(ofSize: 50)
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
        view.addSubview(UrlLabel)
        view.bringSubviewToFront(qrCodeView)
        view.bringSubviewToFront(UrlLabel)
        
//        qrCodeView.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.width.height.equalTo(320)
//        }
        
        UrlLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // FIXME: - let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) 이렇게 수정해보기
    private func initCameraDevice() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { // (.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        cameraDevice = captureDevice
    }
    
    private func initCameraInputData() {
        if let cameraDevice = self.cameraDevice {
            do {
                let input = try AVCaptureDeviceInput(device: cameraDevice)
                captureSession.addInput(input)    //if captureSession.canAddInput(input) { captureSession.addInput(input) }
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func initCameraOutputData() {
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)            //if captureSession.canAddOutput(captureMetadataOutput) { captureSession.addOutput(captureMetadataOutput) }
            
        // Output 데이터가 들어왔을 때, 처리할 Delegate 설정
        // Camera로 들어오는 데이터 타입이 QR코드 임을 명시
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]                 // captureMetadataOutput.availableMetadataObjectTypes
    }
    
    private func displayPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer)
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
        } else {
            // MetaData을 사람이 읽을 수 있는 Data로 캐스팅
            guard let metaDataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
                print("Fail to cast MetaData as AVMetadataMachineReadableCodeObject")
                return
            }
            // QR 데이터인 경우
            if metaDataObj.type == .qr {
                // MetaData을 캡쳐한 직접적인 화면을 가져온다.
                guard let qrCodeObject = videoPreviewLayer.transformedMetadataObject(for: metaDataObj) else { return }
                // 가져온 QR Code 화면을 캡쳐한 위치를 넣어준다.
                self.qrCodeView.frame = qrCodeObject.bounds
                // 작은 곳에서 커지게 애니메이션
                UIView.animate(withDuration: 0.5) {
                    self.qrCodeView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                
                // 여기서 직접적으로 가져온 QR Code 데이터를 해독한다.
                guard let qrCodeStringData = metaDataObj.stringValue else { return }
                //if qrCodeStringData.hasPrefix("http://") || qrCodeStringData.hasPrefix("https://") {
                //UrlTextView.text = qrCodeStringData
                //UrlLabel.setUpLabel(title: qrCodeStringData, podaFont: .caption)
                UrlLabel.text = qrCodeStringData
                UrlLabel.isHidden = false
                UrlLabel.isHighlighted = true
                print(qrCodeStringData)
                //}
            }
        }
    }
}

    // https://m.site.naver.com/1f14g

extension QRViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        //let webViewController = WebViewController(URL)
        //present(webViewController, animated: true, completion: nil)
        return false
    }
}
