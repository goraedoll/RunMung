//
//  SlidingView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//

import SwiftUI

struct HomeSlidingView: View {
    @State private var viewModel = HomeSlidingViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $viewModel.selection) {
                ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                    ZStack {
                        // 카드 배경
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 2, y: 4)
                        
                        HStack(spacing: 0) {
                            GeometryReader { geo in
                                HStack(spacing: 0) {
                                    // 왼쪽: 이미지 (1/3)
                                    Image(slide.imageURL) // 👉 에셋 이름 사용
                                        .resizable()
                                        .interpolation(.high)
                                        .antialiased(true)
                                        .scaledToFit()
                                        .frame(width: geo.size.width / 3, height: 100)
                                        .clipped()
                                    
                                    // 오른쪽: 텍스트 (2/3)
                                    Text(slide.title)
                                        .font(.system(size: 18, weight: .light))
                                        .frame(width: geo.size.width * 2/3, height: 100)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .frame(height: 100)
                        .padding(.horizontal, 16)
                    }
                    .padding()
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 160)
            
            // 인디케이터
            HStack(spacing: 4) {
                ForEach(viewModel.slides.indices, id: \.self) { index in
                    Rectangle()
                        .fill(viewModel.selection == index ? Color.black : Color.gray)
                        .frame(width: 16, height: 2)
                        .animation(.easeInOut, value: viewModel.selection)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
