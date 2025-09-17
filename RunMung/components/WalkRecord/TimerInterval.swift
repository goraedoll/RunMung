//
//  TimerInterval.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//
import Foundation

extension TimeInterval {
    /// 페이스 계산: 총 시간(초) ÷ 거리(km)
    static func paceString(time: TimeInterval, distance: Double) -> String {
        guard distance >= 0.01 else { return "--'--\"" } // 최소 10m 이상일 때만
        let paceSeconds = time / distance
        let minutes = Int(paceSeconds) / 60
        let seconds = Int(paceSeconds) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}
