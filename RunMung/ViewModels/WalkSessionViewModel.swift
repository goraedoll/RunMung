//
//  WalkSessionViewModel.swift
//  RunMung
//
//  Created by 고래돌 on 9/22/25.
//

import Foundation
import SwiftData
import CoreLocation

class WalkSessionViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var totalDistance: Double = 0
    @Published var isPaused: Bool = true
    @Published var locations: [CLLocation] = [] // GPS 경로 관리
    
    private var timerManager = TimerManager()
    private var distanceTracker = DistanceTracker()
    
    init() {
        // TimerManager와 DistanceTracker 값을 바인딩
        timerManager.$elapsedTime
            .assign(to: &$elapsedTime)
        timerManager.$isPaused
            .assign(to: &$isPaused)
        distanceTracker.$totalDistance
            .assign(to: &$totalDistance)
        distanceTracker.$locations
            .assign(to: &$locations)
    }
    
    // 시간 문자열 반환
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func start() {
        timerManager.start()
        distanceTracker.start()
    }
    
    func stop() {
        timerManager.stop()
        distanceTracker.stop()
    }
    
    func reset() {
        timerManager.reset()
        distanceTracker.reset()
        locations.removeAll()
    }
    
    func save(to context: ModelContext) {
        let record = RunRecord(
            date: Date(),
            distance: totalDistance,
            elapsedTime: elapsedTime,
            pace: TimeInterval.paceString(time: elapsedTime, distance: totalDistance)
        )
        
        for loc in locations {
            let point = RunLocation(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                timestamp: loc.timestamp,
                speed: loc.speed
            )
            record.routePoints.append(point)
        }
        context.insert(record)
    }
}
