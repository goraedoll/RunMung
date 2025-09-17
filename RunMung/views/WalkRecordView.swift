//
//  WalkRecordView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct WalkRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPaused = true
    
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
                        Text("6'15\"")
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("128")
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("시간")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("00:42:31")
                            .font(.title2).bold()
                            .foregroundColor(.coral)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 중간 총 이동거리
                VStack {
                    Text("5.23")
                        .font(.system(size: 120, weight: .heavy))
                        .foregroundColor(.coral)
                        .italic()
                    Text("키로미터")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 일시정지 버튼 (원형)
                Button {
                    withAnimation(.none) {
                        isPaused.toggle()
                    }
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.coral)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                // 음악 버튼 (캡슐형)
                Button {
                    print("음악 연결하기 눌림")
                } label: {
                    Text("음악 연결하기")
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
    }
}

#Preview {
    MainTabView()
}

