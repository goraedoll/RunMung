//
//  RunMungApp.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//

import SwiftUI
import SwiftData

@main
struct RunMungApp: App {
    @StateObject private var timerManager = TimerManager() // 전역적으로 총 산책 시간을 사용할 수 있게 함
    @StateObject private var distanceTracker = DistanceTracker() // 전역적으로 총 거리를 사용할 수 있게 함
    var body: some Scene {
        WindowGroup {
            MainTabView()   // 앱 실행 시 가장 먼저 띄우는 화면
                .environmentObject(timerManager)
                .environmentObject(distanceTracker)
        }
        .modelContainer(for: RunRecord.self)
    }
}

#Preview("MainTabView") {
    MainTabView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}

