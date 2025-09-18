//
//  ResetButton.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct ResetButton: View {
    @Binding var isPaused: Bool
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var distanceTracker: DistanceTracker
    
    var onMessageChange: (String?) -> Void // 메세지 부모에게 전달
    @State private var isPressingReset = false
    
    
    var body: some View {
        Group {
            if isPaused && timerManager.elapsedTime > 0 {
                // 일시정지 상태 → 리셋 버튼 활성화
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
                                if pressing {
                                    onMessageChange("초기화하려면 3초 이상 꾹 눌러주세요.")
                                }
                                // pressing=false에서는 메시지를 지우지 않는다
                            }
                        },
                        perform: {
                            
                            timerManager.reset()
                            distanceTracker.reset()
                            isPaused = true
                            
                            withAnimation {
                                onMessageChange("초기화 되었습니다.")
                            }


                            // 2초 후 메시지 제거
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    onMessageChange(nil)
                                }
                            }
                        }
                    )
            } else {
                // 실행 중 → 잠금 상태
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
}


#Preview("Walk record preview") {
    WalkRecordView()
        .environmentObject(DistanceTracker()) // 프리뷰용 객체 주입
        .environmentObject(TimerManager()) // 프리뷰용 객체 주입
}
