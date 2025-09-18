//
//  CustuomCameraView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//
import SwiftUI

struct CustomCameraView: View {
    @StateObject private var controller = CameraController()
    @Environment(\.dismiss) private var dismiss
    var onCapture: (UIImage) -> Void

    @State private var zoomFactor: CGFloat = 1.0

    var body: some View {
        ZStack {
            CameraPreview(controller: controller)
                .ignoresSafeArea()

            // Top controls
            VStack {
                HStack {
                    Button(action: { controller.toggleCamera() }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: toggleFlash) {
                        Image(systemName: flashIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                Spacer()

                // Shutter
                Button(action: { controller.capturePhoto() }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 74, height: 74)
                        .overlay(Circle().stroke(.black.opacity(0.7), lineWidth: 3))
                        .padding(.bottom, 28)
                }
            }
        }
        // Pinch to zoom
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let newFactor = zoomFactor * value
                    controller.zoom(newFactor)
                }
                .onEnded { value in
                    zoomFactor *= value
                }
        )
        // Receive captured image
        .onReceive(controller.$capturedImage) { img in
            guard let img else { return }
            onCapture(img)
            dismiss()
        }
    }

    private func toggleFlash() {
        switch controller.flashMode {
        case .auto: controller.flashMode = .on
        case .on:   controller.flashMode = .off
        case .off:  controller.flashMode = .auto
        @unknown default: controller.flashMode = .auto
        }
    }
    private var flashIcon: String {
        switch controller.flashMode {
        case .auto: return "bolt.badge.a"
        case .on:   return "bolt.fill"
        case .off:  return "bolt.slash"
        @unknown default: return "bolt.badge.a"
        }
    }
}
