//
//  TimerAttributes.swift
//  RunMung
//

import Foundation   // ✅ Date를 쓰려면 필요
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date   // 시작 시각
    }
    
    var title: String
}
