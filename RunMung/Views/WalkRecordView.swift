//
//  WalkRecordView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI
import ActivityKit

struct WalkRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var resetMessage: String? = nil
    @State private var displayedPace: String = "--'--\""
    @State private var lastUpdatedSecond: Int = 0
    @State private var isPressingSave = false
    
    @State private var showCamera = false // 카메라 뷰 이동
    @State private var showPhotoAlert = false // 카메라 알람

    @EnvironmentObject var timerManager: TimerManager  // 시간 상태
    @EnvironmentObject var distanceTracker: DistanceTracker // 총 거리 상태 꺼내오기
    
    @EnvironmentObject var photoManager: PhotoManager // 사진 시간 상태
    @EnvironmentObject var photoDisplayManager: PhotoDisplayManager // 사진용 총 시간
    
    @Environment(\.modelContext) private var modelContext // SwiftData 컨텍스트 주입받기
    
    var body: some View {
        ZStack {
            // 배경 (밝은 화이트 → 연코랄 그라데이션)
            LinearGradient(
                colors: [Color.white, Color.coral.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // 닫기 버튼
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                
                // 상단 정보 (페이스, BPM, 시간)
                HStack {
                    VStack {
                        Text("페이스")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(displayedPace)
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .onReceive(timerManager.$elapsedTime) { time in
                        let currentSecond = Int(time)
                        if currentSecond % 10 == 0, currentSecond != lastUpdatedSecond {
                            displayedPace = TimeInterval.paceString(
                                time: time,
                                distance: distanceTracker.totalDistance
                            )
                            lastUpdatedSecond = currentSecond
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("시간")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(timerManager.formattedTime)
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 총 이동거리
                VStack {
                    Text(String(format: "%.2f", distanceTracker.totalDistance))
                        .font(.system(size: 120, weight: .heavy))
                        .foregroundColor(.coral)
                        .italic()
                    Text("키로미터")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    if let resetMessage = resetMessage {
                        Text(resetMessage)
                            .id(resetMessage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.gray)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                            .padding(.top, 4)
                            .animation(.easeInOut(duration: 0.3), value: resetMessage)
                    }
                }
                
                Spacer()
                
                ZStack {
                    if timerManager.isPaused && timerManager.elapsedTime > 0 {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.coral)
                            .frame(width: 40, height: 40)
                            .background(isPressingSave ? Color.coral.opacity(0.3) : Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .scaleEffect(isPressingSave ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isPressingSave)
                            .onLongPressGesture(
                                minimumDuration: 3,
                                pressing: { pressing in
                                    withAnimation {
                                        isPressingSave = pressing
                                        if pressing {
                                            resetMessage = "저장하려면 3초 이상 꾹 눌러주세요."
                                        }
                                    }
                                },
                                perform: {
                                    let record = RunRecord(
                                        date: Date(),
                                        distance: distanceTracker.totalDistance,
                                        elapsedTime: timerManager.elapsedTime,
                                        pace: displayedPace
                                    )
                                    
                                    
                                    modelContext.insert(record)
                                    resetMessage = "기록이 저장되었습니다."
                                    print("저장 완료: \(record)")

                                    // ✅ 사진용 매니저에 값 복사
                                    photoManager.elapsedTime = timerManager.elapsedTime
                                    photoManager.formattedTime = timerManager.formattedTime
                                    photoDisplayManager.totalDistance = distanceTracker.totalDistance
                                    photoDisplayManager.pace = displayedPace

                                    // 저장 후 초기화
                                    timerManager.reset()
                                    distanceTracker.reset()
                                    displayedPace = "--'--\""
                                    lastUpdatedSecond = 0
                                    
                                    // Live Activity 종료
                                    LiveActivityManager.shared.end()

                                    // ✅ Alert 띄우기
                                    showPhotoAlert = true
                                }
                            )
                            .offset(x:-80, y: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 큰 Play/Pause 버튼 (항상 중앙)
                    Button {
                        if timerManager.isPaused {
                            timerManager.start()
                            distanceTracker.start()
                            resetMessage = nil
                        } else {
                            timerManager.stop()
                            distanceTracker.stop()
                        }
                    } label: {
                        Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.coral)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }


                    // Reset 버튼
                    ResetButton(timerManager: timerManager, distanceTracker: distanceTracker) { message in
                        resetMessage = message
                    }
                    .offset(x:80, y: 10)
                }

                // 지도 보기
                Button {
                    print("지도 보기")
                } label: {
                    Label("지도 보기", systemImage: "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.coral)
                        .clipShape(Capsule())
                        .shadow(radius: 3)
                }
            }
            .padding()
        }
        // 저장 후 Alert
        .alert("인증 사진을 찍겠습니까?", isPresented: $showPhotoAlert) {
            Button("취소", role: .cancel) {}
            Button("확인") {
                showCamera = true
            }
        }
        // ✅ CameraView를 모달(풀스크린)로 띄우기
        .fullScreenCover(isPresented: $showCamera) {
            CameraView()
        }
    }
}

#Preview("Walk record preview") {
    NavigationStack {
        WalkRecordView()
            .environmentObject(DistanceTracker())
            .environmentObject(TimerManager())
            .environmentObject(PhotoManager())
            .environmentObject(PhotoDisplayManager())
    }
}
