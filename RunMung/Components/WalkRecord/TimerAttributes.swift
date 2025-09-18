//
//  TimerAttributes.swift
//  RunMung
//

import Foundation   // ✅ Date를 쓰려면 필요
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date?      // 실행 기준 시각 (없으면 멈춤 상태)
        var elapsedTime: TimeInterval // 누적 시간
        var isPaused: Bool        // 현재 일시정지 여부
    }
    
    var title: String
}
