//
//  LiveActivityManager.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import ActivityKit
import Foundation

final class LiveActivityManager {
    static var shared = LiveActivityManager()
    private var activity: Activity<TimerAttributes>?

    private init() {}

    func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = TimerAttributes(title: "런닝 타이머")
        let state = TimerAttributes.ContentState(startDate: Date()) // 지금 시각 저장
        do {
            let content = ActivityContent(state: state, staleDate: nil)
            activity = try Activity.request(
                attributes: attributes,
                content: content
            )
            print("✅ Live Activity 시작됨")
        } catch {
            print("❌ Live Activity 시작 실패:", error.localizedDescription)
        }
    }

    // 업데이트는 필요 없음! startDate만 넘기면 시스템이 알아서 경과 시간 갱신
    func end() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
            print("🛑 Live Activity 종료됨")
        }
    }
}
