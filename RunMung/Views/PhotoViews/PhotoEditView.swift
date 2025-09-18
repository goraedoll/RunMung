//
//  PhotoEditView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI
import PhotosUI



struct PhotoEditView: View {
    // 입력
    var image: UIImage            // CameraView에서 축소된 이미지 전달
    var onSave: (UIImage) -> Void // 저장 후 부모에게 전달

    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var photoDisplayManager: PhotoDisplayManager


    // MARK: - 상태
    @State private var baseOffset: CGSize = .zero              // 누적 오프셋
    @GestureState private var dragTranslation: CGSize = .zero  // 현재 드래그 이동량
    @State private var scale: CGFloat = 1.0
    @State private var textColor: Color = .white
    @State private var showSavedAlert = false
    @State private var isZoomAnimating = false                 // 줌 애니메이션 중 여부
    



    // MARK: - UI 상수
    private let zoomStep: CGFloat = 0.2
    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 3.0
    private let zoomAnim: Double = 0.20

    // 비율 (4:5)
    private var instaWidth: CGFloat { UIScreen.main.bounds.width - 32 }
    private var instaHeight: CGFloat { instaWidth * 5 / 4 }

    var body: some View {
        VStack(spacing: 0) {
            // ✅ 캔버스 (여기서 드래그 제스처 전체 처리)
            previewCanvas
                .frame(width: instaWidth, height: instaHeight)
                .padding(.vertical, 16)

            // 🎛️ 툴바 (확대/축소 + 컬러피커만)
            toolbarRow
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            // 저장 / 초기화
            actionRow
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .navigationTitle("사진 편집")
        .alert("앨범에 저장 완료!", isPresented: $showSavedAlert) {
            Button("확인") { dismiss() }
        }
    }

    // MARK: - 캔버스
    private var previewCanvas: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: instaWidth, height: instaHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(radius: 8)

            overlayCard
                // 🔑 순서 중요: 스케일 → 오프셋
                .scaleEffect(scale)
                .offset(totalOffset)
                // 오프셋 변화에는 암묵적 애니메이션 금지 (줌 애니메이션과 충돌 방지)
                .animation(nil, value: dragTranslation)
                .animation(nil, value: baseOffset)
        }
        .contentShape(Rectangle()) // 빈 공간도 드래그 히트
        .gesture(
            DragGesture(minimumDistance: 2)
                .updating($dragTranslation) { value, state, _ in
                    guard !isZoomAnimating else { return }
                    state = value.translation
                }
                .onEnded { value in
                    guard !isZoomAnimating else { return }
                    baseOffset.width += value.translation.width
                    baseOffset.height += value.translation.height
                }
        )
        .clipped()
    }

    private var totalOffset: CGSize {
        CGSize(
            width: baseOffset.width + dragTranslation.width,
            height: baseOffset.height + dragTranslation.height
        )
    }

    // MARK: - 툴바 (Move 제거)
    private var toolbarRow: some View {
        HStack(spacing: 12) {
            Button(action: zoomIn) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
            .foregroundColor(.primary)

            Button(action: zoomOut) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
            .foregroundColor(.primary)

            // 바로 적용되는 컬러 피커
            ColorPicker("", selection: $textColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 44, height: 44)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - 액션 버튼
    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                // 전체 초기화(원복)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    baseOffset = .zero
                    scale = 1.0
                    textColor = .white
                }
            } label: {
                Label("초기화", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .foregroundColor(.primary)
            .cornerRadius(10)

            Button {
                saveAsSeen()
            } label: {
                Label("사진 저장하기", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.coral)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    // MARK: - 줌 제어
    private func zoomIn() {
        guard !isZoomAnimating else { return }
        isZoomAnimating = true
        withAnimation(.easeInOut(duration: zoomAnim)) {
            scale = min(scale + zoomStep, maxZoom)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + zoomAnim + 0.02) {
            isZoomAnimating = false
        }
    }

    private func zoomOut() {
        guard !isZoomAnimating else { return }
        isZoomAnimating = true
        withAnimation(.easeInOut(duration: zoomAnim)) {
            scale = max(scale - zoomStep, minZoom)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + zoomAnim + 0.02) {
            isZoomAnimating = false
        }
    }

    // MARK: - 오버레이 카드
    private var overlayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐶 ★ 80")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(textColor)

            Divider().background(textColor.opacity(0.7))

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    Text("총 거리").foregroundColor(textColor.opacity(0.8))
                    // ✅ 저장된 거리 사용
                    Text(String(format: "%.2f km", photoDisplayManager.totalDistance))
                        .bold().foregroundColor(textColor)
                }
                GridRow {
                    Text("페이스").foregroundColor(textColor.opacity(0.8))
                    // ✅ 저장된 페이스 사용
                    Text(photoDisplayManager.pace)
                        .bold().foregroundColor(textColor)
                }
                GridRow {
                    Text("산책 시간").foregroundColor(textColor.opacity(0.8))
                    // ✅ 저장된 시간 사용
                    Text(photoManager.formattedTime)
                        .bold().foregroundColor(textColor)
                }
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(12)
        .frame(maxWidth: 180)
    }


    // MARK: - 저장 (보이는 그대로, 4:5)
    private func saveAsSeen() {
        let renderView = ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: instaWidth, height: instaHeight)
                .clipped()

            overlayCard
                // 저장 렌더에서도 동일한 변환 순서 유지
                .scaleEffect(scale)
                .offset(totalOffset)
        }
        .frame(width: instaWidth, height: instaHeight)

        let renderer = ImageRenderer(content: renderView)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = true

        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            onSave(uiImage)
            showSavedAlert = true
        }
    }
}

#Preview("PhotoEditView") {
    NavigationStack {
        PhotoEditView(image: UIImage(systemName: "photo")!) { _ in }
            .environmentObject(PhotoManager())
            .environmentObject(PhotoDisplayManager())
    }
}
