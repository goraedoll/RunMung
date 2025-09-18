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
        
        let state = TimerAttributes.ContentState(
            startDate: Date(),       // 시작 시각
            elapsedTime: 0,          // 초기 경과 시간
            isPaused: false          // 시작했으니 일시정지 아님
        )
        
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

    /// 경과 시간 보정해서 Live Activity 업데이트
    func update(elapsedTime: TimeInterval, isPaused: Bool) {
        guard let activity else { return }
        
        let state = TimerAttributes.ContentState(
            startDate: isPaused ? nil : Date().addingTimeInterval(-elapsedTime),
            elapsedTime: elapsedTime,
            isPaused: isPaused
        )
        
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
            print("🔄 Live Activity 업데이트됨 (isPaused=\(isPaused), elapsed=\(elapsedTime))")
        }
    }


    func end() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
            print("🛑 Live Activity 종료됨")
        }
    }
}
