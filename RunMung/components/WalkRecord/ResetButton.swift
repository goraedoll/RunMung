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
                    .background(isPressingReset ? Color.red.opacity(0.3) : Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .scaleEffect(isPressingReset ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isPressingReset)
                    .onLongPressGesture(
                        minimumDuration: 2,
                        pressing: { pressing in
                            withAnimation {
                                isPressingReset = pressing
                                onMessageChange(pressing ? "초기화하려면 3초 이상 꾹 눌러주세요." : nil)
                            }
                        },
                        perform: {
                            timerManager.reset()
                            isPaused = true
                            withAnimation {
                                onMessageChange("초기화 되었습니다.")
                            }
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


#Preview {
    WalkRecordView()
}
