//
//  PhotosView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI

extension UIImage {
    func croppedToSquare() -> UIImage {
        let cgImage = self.cgImage!
        let contextSize = CGSize(width: cgImage.width, height: cgImage.height)

        // 짧은 변 기준으로 정사각형 잘라내기
        let side = min(contextSize.width, contextSize.height)
        let posX = (contextSize.width - side) / 2
        let posY = (contextSize.height - side) / 2
        let rect = CGRect(x: posX, y: posY, width: side, height: side)

        if let imageRef = cgImage.cropping(to: rect) {
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        }

        return self
    }
}

/// 정사각형 Masonry 레이아웃 (가로 N칸)
struct MasonryLayout: Layout {
    var columns: Int
    var spacing: CGFloat

    struct Cache {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> Cache {
        var cache = Cache()
        updateCache(&cache, subviews: subviews, proposal: .unspecified)
        return cache
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for (i, subview) in subviews.enumerated() where i < cache.frames.count {
            let frame = cache.frames[i]
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func updateCache(_ cache: inout Cache, subviews: Subviews, proposal: ProposedViewSize) {
        let totalWidth = proposal.width ?? UIScreen.main.bounds.width
        let columnWidth = (totalWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)

        var columnHeights = Array(repeating: CGFloat(0), count: columns)
        var frames: [CGRect] = []

        for _ in subviews {
            let shortest = columnHeights.enumerated().min(by: { $0.element < $1.element })!.offset

            let x = CGFloat(shortest) * (columnWidth + spacing)
            let y = columnHeights[shortest]
            let frame = CGRect(x: x, y: y, width: columnWidth, height: columnWidth)

            frames.append(frame)
            columnHeights[shortest] += columnWidth + spacing
        }

        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: columnHeights.max() ?? 0)
    }
}

/// 정사각형 Masonry 레이아웃 (가로 3칸, 셀 간격 2px, 전체 패딩 없음)
struct PhotosView: View {
    @State private var photos: [PhotoItem] = []
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            HomeHeaderView()
            HomeTitleView(text: "🐶")

            ScrollView {
                MasonryLayout(columns: 3, spacing: 2) {
                    ForEach(photos.indices, id: \.self) { i in
                        ZStack {
                            Image(uiImage: photos[i].image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .onLongPressGesture {
                                    withAnimation {
                                        selectedIndex = i
                                    }
                                }

                            if selectedIndex == i {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button {
                                            deleteImage(at: i)
                                        } label: {
                                            Image(systemName: "trash.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.red)
                                                .shadow(radius: 4)
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadAllImages()
        }
    }

    // MARK: - 이미지 삭제
    private func deleteImage(at index: Int) {
        let fileName = photos[index].fileName
        FileManager.deleteImageFromDocuments(name: fileName) // 실제 파일 삭제
        photos.remove(at: index) // 리스트에서 제거
        selectedIndex = nil
    }

    // MARK: - Documents 폴더에서 이미지 불러오기
    private func loadAllImages() {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        do {
            let files = try FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil)
            let jpgFiles = files.filter { $0.pathExtension.lowercased() == "jpg" }

            photos = jpgFiles.compactMap { url in
                let name = url.deletingPathExtension().lastPathComponent
                if let img = UIImage(contentsOfFile: url.path)?.croppedToSquare() {
                    return PhotoItem(fileName: name, image: img)
                }
                return nil
            }
        } catch {
            print("❌ 불러오기 실패:", error.localizedDescription)
        }
    }
}

#Preview {
    PhotosView()
}
