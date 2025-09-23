//
//  HomeSelectTitleView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//
import SwiftUI

struct HomeSelectTitleView: View {
    @Binding var selectedIndex: Int
    
    private let titles = ["바로 시작", "댕구르르 가이드"]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                Button {
                    selectedIndex = index
                } label: {
                    Text(title)
                        .font(.system(size: 16, weight: selectedIndex == index ? .regular : .light))
                        .foregroundColor(selectedIndex == index ? .black : .gray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // HStack 자체를 왼쪽 정렬
        .padding(.horizontal, 16)
    }
}

#Preview {
    MainTabView()
}
