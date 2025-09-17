//
//  TimerManager.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer? = nil
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }
}
