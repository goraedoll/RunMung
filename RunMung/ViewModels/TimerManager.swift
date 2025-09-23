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
    @Published var isPaused: Bool = true
    
    private var timer: Timer? = nil
    private var isRunning = false
    private var lastStartDate: Date?
    private var backgroundEnteredDate: Date?
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func start() {
        guard isPaused else { return }
        isPaused = false
        lastStartDate = Date()
        startTimer()
        
        if elapsedTime == 0 {
            LiveActivityManager.shared.start()
        }
        LiveActivityManager.shared.update(elapsedTime: elapsedTime, isPaused: false)
    }

    func stop() {
        guard !isPaused else { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
        if let lastStart = lastStartDate {
            elapsedTime += Date().timeIntervalSince(lastStart)
        }
        lastStartDate = nil
        
        // 일시정지 상태 반영
        LiveActivityManager.shared.update(elapsedTime: elapsedTime, isPaused: true)
    }

    func reset() {
        stop()
        elapsedTime = 0
        LiveActivityManager.shared.update(elapsedTime: 0, isPaused: true)
    }

    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let lastStart = self.lastStartDate else { return }
            let now = Date()
            self.elapsedTime += now.timeIntervalSince(lastStart)
            self.lastStartDate = now
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc private func appMovedToBackground() {
        guard isRunning else { return }
        backgroundEnteredDate = Date()
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func appMovedToForeground() {
        guard isRunning, let backgroundEnteredDate else { return }
        elapsedTime += Date().timeIntervalSince(backgroundEnteredDate)
        lastStartDate = Date()
        startTimer()
    }
}
