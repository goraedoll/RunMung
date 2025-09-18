//
//  CameraView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//
import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isCertified = false
    
    init(previewImage: UIImage? = nil) {
        _capturedImage = State(initialValue: previewImage)
    }
    
    private var previewWidth: CGFloat { UIScreen.main.bounds.width - 32 }
    private var previewHeight: CGFloat { previewWidth * 5 / 4 }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("인증 사진")
                    .font(.title)
                    .bold()
                
                if let image = capturedImage {
                    NavigationLink {
                        PhotoEditView(image: image) { edited in
                            capturedImage = edited
                            isCertified = true
                        }
                        .onDisappear {
                            UIGraphicsEndImageContext()
                        }
                    } label: {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: previewWidth, height: previewHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // ✅ 인증 마크 오버레이
                            if !isCertified {
                                VStack {
                                    Spacer()
                                    Text("🏅인증")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.coral.opacity(0.8))
                                        .clipShape(Capsule())
                                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                        .padding(.bottom, 24) // 사진 하단 쪽에 위치
                                }
                                .frame(width: previewWidth, height: previewHeight)
                            }
                        }
                        .frame(width: previewWidth, height: previewHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.coral, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                
                if capturedImage != nil && isCertified {
                    Button("공유하기") {
                        // 공유 기능
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.coral)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Button("사진 촬영하기") {
                    showCamera = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    Color.coral.opacity(capturedImage != nil && isCertified ? 0.6 : 1.0)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                
                Button("닫기") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer() // 나머지 공간을 아래로 밀어줌
            }
            .frame(maxHeight: .infinity, alignment: .top) // 항상 위에서부터 정렬
            .safeAreaInset(edge: .top) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CustomCameraView { img in
                    capturedImage = img
                }
            }
        }
    }
}


struct MockCameraView: View {
    var body: some View {
        CameraView(previewImage: UIImage(systemName: "photo"))
    }
}

#Preview("Camera Mock - 이미지 없음") {
    NavigationStack {
        CameraView() // previewImage 생략 → nil 상태
    }
}

#Preview("Camera Mock - 이미지 있음") {
    NavigationStack {
        CameraView(previewImage: UIImage(systemName: "photo"))
    }
}
