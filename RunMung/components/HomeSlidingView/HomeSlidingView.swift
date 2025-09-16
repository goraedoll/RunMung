//
//  SlidingView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//
import SwiftUI

import SwiftUI

struct SlidingView: View {
    var body: some View {
        TabView {
            ForEach(1..<5) { index in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.3))
                    .overlay(Text("슬라이드 \(index)"))
                    .padding()
            }
        }
        .tabViewStyle(.page)   // 페이징 스타일 (좌우 스와이프)
        .frame(height: 200)
    }
}
