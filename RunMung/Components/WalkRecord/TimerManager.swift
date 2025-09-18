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
        guard !isRunning else { return }
        isRunning = true
        lastStartDate = Date()
        startTimer()
        
        // ✅ Live Activity 시작
        LiveActivityManager.shared.start()
    }
    
    func stop() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
        if let lastStart = lastStartDate {
            elapsedTime += Date().timeIntervalSince(lastStart)
        }
        lastStartDate = nil
        
        // Live Activity 종료
        LiveActivityManager.shared.end()
    }

    func reset() {
        stop()
        elapsedTime = 0
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
