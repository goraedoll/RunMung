//
//  SettingView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct SettingView: View {
    @State private var isPushOn = true
    @State private var isDarkModeOn = false
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack(spacing: 0) {
                    HomeHeaderView()
                    HomeTitleView(text: "설정")
                    
                    List {
                        Section(header: Text("계정")) {
                            Text("프로필 관리")
                            Text("비밀번호 변경")
                        }
                        
                        Section(header: Text("앱 설정")) {
                            Toggle(isOn: $isPushOn) { Text("푸시 알림") }
                            Toggle(isOn: $isDarkModeOn) { Text("다크 모드") }
                        }
                        
                        Section(header: Text("기타")) {
                            Text("앱 버전 1.0.0")
                            Text("도움말 / 문의하기")
                        }
                    }
                }
            }
        }
    }
}

#Preview("MainTabView") {
    MainTabView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}

