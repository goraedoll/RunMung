//
//  ResetButton.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI
import UIKit

struct ResetButton: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var distanceTracker: DistanceTracker
    var onMessageChange: (String?) -> Void
    @State private var isPressingReset = false
    
    var body: some View {
        Group {
            if timerManager.isPaused && timerManager.elapsedTime > 0 {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.coral)
                    .frame(width: 40, height: 40)
                    .background(isPressingReset ? Color.coral.opacity(0.3) : Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .scaleEffect(isPressingReset ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isPressingReset)
                    .onLongPressGesture(
                       minimumDuration: 3,
                       pressing: { pressing in
                           withAnimation {
                               isPressingReset = pressing
                           }
                           
                           if pressing {
                               impact(style: .light) // 시작 진동
                               onMessageChange("초기화하려면 3초 이상 꾹 눌러주세요.")
                           }
                       },
                       perform: {
                           notify(.success) // 완료 진동
                           
                           timerManager.reset()
                           distanceTracker.reset()
                           LiveActivityManager.shared.end()
                           
                           withAnimation {
                               onMessageChange("초기화 되었습니다.")
                           }
                           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               withAnimation { onMessageChange(nil) }
                           }
                       }
                   )
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.gray.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
    }
    
    // MARK: - Haptic Helpers
    private func impact(style: UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func notify(_ type: UINotificationFeedbackGenerator.FeedbackType){
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}


#Preview("Walk record preview") {
    WalkRecordView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}
