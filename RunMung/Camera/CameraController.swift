import AVFoundation
import UIKit
import Combine

final class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // Session
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()

    // Inputs
    private(set) var currentInput: AVCaptureDeviceInput?
    private(set) var isFrontCamera = false

    // Preview
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // State
    @Published var capturedImage: UIImage?
    var flashMode: AVCaptureDevice.FlashMode = .auto

    // MARK: - Configuration
    func startSession(in view: UIView) {
        sessionQueue.async(group: nil, qos: .userInitiated, flags: []) {
            guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // input
            if self.currentInput == nil {
                let position: AVCaptureDevice.Position = .back
                if let input = self.createInput(position: position),
                   self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.currentInput = input
                    self.isFrontCamera = (position == .front)
                }
            }

            // output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = view.bounds
                view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                view.layer.addSublayer(layer)
                self.previewLayer = layer
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func updatePreviewFrame(to frame: CGRect) {
        previewLayer?.frame = frame
        if let connection = previewLayer?.connection {
            if #available(iOS 17.0, *) {
                connection.videoRotationAngle = 90 // portrait
            } else {
                connection.videoOrientation = .portrait
            }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func createInput(position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        guard let device = discovery.devices.first else { return nil }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            print("Input error:", error)
            return nil
        }
    }

    // MARK: - Controls
    func toggleCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            if let input = self.currentInput {
                self.session.removeInput(input)
            }
            self.isFrontCamera.toggle()
            let newPos: AVCaptureDevice.Position = self.isFrontCamera ? .front : .back
            if let newInput = self.createInput(position: newPos),
               self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentInput = newInput
            }
            self.session.commitConfiguration()
        }
    }

    func zoom(_ factor: CGFloat) {
        guard let device = currentInput?.device else { return }
        do {
            try device.lockForConfiguration()
            let maxZoom = min(5.0, device.activeFormat.videoMaxZoomFactor) // UX상 5x 제한
            device.videoZoomFactor = max(1.0, min(factor, maxZoom))
            device.unlockForConfiguration()
        } catch {
            print("Zoom lock error:", error)
        }
    }

    // MARK: - Capture
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if currentInput?.device.hasFlash == true,
           photoOutput.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Delegate
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("Capture error:", error ?? NSError(domain: "capture", code: -1))
            return
        }

        // 1) 원본 포토 앨범 저장
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        // 2) 축소본만 앱에서 사용
        let resized = image.resized(longerSideTo: 1080)

        // 🚨 원본 참조 제거 (ARC 즉시 해제 가능)
        DispatchQueue.main.async {
            self.capturedImage = resized
        }
    }
}
