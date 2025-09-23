//
//  MainTabView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTabIndex = 2
    
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            
            // home
            PhotosView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)

            // 챗 화면
            DogChatView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
                .tag(1)
            
            // 플랜 화면
            ContentView()
                .tabItem {
                    Label("런멍", systemImage: "pawprint.fill")
                }
                .tag(2)
            
            // 순위
            RecordView()
                .tabItem {
                    Label("기록", systemImage: "calendar")
                }
                .tag(3)
            
            // 설정
            DogClassifierView()
                .tabItem {
                    Label("AI", systemImage: "dog.circle")
                }
                .tag(4)
            
//            SettingView()
//                .tabItem {
//                    Label("설정", systemImage: "gearshape.fill")
//                }
//                .tag(4)
        }
    }
}



#Preview("MainTabView") {
    MainTabView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}

