//
//  WalkRecordView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI
import ActivityKit
import UIKit

struct WalkRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext // SwiftData 컨텍스트 주입받기
    @StateObject private var session = WalkSessionViewModel() // 세션으로 GPS, 거리, 지속시간 관리하기
    
    @State private var resetMessage: String? = nil
    @State private var displayedPace: String = "--'--\""
    @State private var lastUpdatedSecond: Int = 0
    @State private var isPressingSave = false
    
    @State private var showCamera = false // 카메라 뷰 이동
    @State private var showPhotoAlert = false // 카메라 알람
    
    var body: some View {
        ZStack {
            // 배경 연코랄 그라데이션
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
                    .onReceive(session.$elapsedTime) { time in
                        let currentSecond = Int(time)
                        if currentSecond % 10 == 0, currentSecond != lastUpdatedSecond {
                            displayedPace = TimeInterval.paceString(
                                time: time,
                                distance: session.totalDistance
                            )
                            lastUpdatedSecond = currentSecond
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("시간")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(session.formattedTime)
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 총 이동거리
                VStack {
                    Text(String(format: "%.2f", session.totalDistance))
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
                // 저장 버튼 (일시정지 상태일 때만)
                if session.isPaused && session.elapsedTime > 0 {
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
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.prepare()
                                        generator.impactOccurred()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            if isPressingSave {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            if isPressingSave {
                                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                            }
                                        }
                                    } else {
                                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    }
                                }
                            },
                            perform: {
                                session.save(to: modelContext)
                                resetMessage = "기록이 저장되었습니다."
                                
                                // Live Activity 종료
                                LiveActivityManager.shared.end()
                                
                                // 저장 성공 햅틱
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                
                                // Alert 띄우기
                                showPhotoAlert = true
                                
                                // 상태 초기화
                                displayedPace = "--'--\""
                                lastUpdatedSecond = 0
                            }
                        )
                        .offset(x:-80, y: 10)
                        .transition(.scale.combined(with: .opacity))
                }
                    
                    // Play / Pause 버튼
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: session.isPaused ? .medium : .light)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        if session.isPaused {
                            session.start()
                            resetMessage = nil
                        } else {
                            session.stop()
                        }
                    } label: {
                        Image(systemName: session.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.coral)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    
                    // Reset 버튼
                    Button {
                        session.reset()
                        resetMessage = "리셋되었습니다."
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.coral)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .offset(x:80, y: 10)
                }

                // 지도 보기
                Button {
                    print("지도 보기 (추후 구현)")
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
        .alert("인증 사진을 찍겠습니까?", isPresented: $showPhotoAlert) {
            Button("취소", role: .cancel) {}
            Button("확인") {
                showCamera = true
            }
        }
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
