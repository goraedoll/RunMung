//
//  ContentView.swift
//  RunMung
//
//  Created by 고래돌 on 9/10/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            HomeMapView()
                .padding(.top, 260)
                .ignoresSafeArea()
            
            VStack(spacing: 4) {
                HomeHeaderView()
                HomeTitleView(text: "🐶 RunMung")
                HomeSelectTitleView(selectedIndex: $selectedIndex)
                
                // 위에서 전환되는 콘텐츠만 TabView로
                TabView(selection: $selectedIndex) {
                    VStack(spacing: 0) {
                        HomeSlidingView()
                        Spacer()
                        HomeActiveButtonView()
                    }
                    .tag(0)
                    
                    HomeGuideView()
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // 점 숨김
                .animation(.easeInOut, value: selectedIndex)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    MainTabView()
}


#Preview {
    MainTabView()
}
