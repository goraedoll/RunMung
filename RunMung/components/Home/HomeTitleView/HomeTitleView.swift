//
//  HomeTitleView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct HomeTitleView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .semibold))
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .leading) // ✅ 높이 고정
            .padding(.horizontal, 16)
            .background(Color.white) // 확인용
    }
}

#Preview("MainTabView") {
    MainTabView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}

