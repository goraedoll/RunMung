//
//  HomeGuideView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct HomeGuideView: View {
    var body: some View {
        VStack {
            Text("HomeGuideView")
            Spacer()
            Text("contents")
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 화면 전체 크기 채우기
        .background(Color.white) // 배경 흰색
    }
}

#Preview {
    MainTabView()
}
