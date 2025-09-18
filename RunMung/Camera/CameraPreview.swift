//
//  CameraPreview.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI

struct CameraPreview: UIViewRepresentable {
    let controller: CameraController

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        controller.startSession(in: v)
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        controller.updatePreviewFrame(to: uiView.bounds)
    }
}
