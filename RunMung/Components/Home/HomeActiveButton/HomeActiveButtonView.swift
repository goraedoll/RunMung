//
//  HomeActiveButtonView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//
import SwiftUI

public struct HomeActiveButtonView: View {
    @State private var showWalkRecord = false
    
    
    public var body: some View {
        VStack {
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    // 설정 버튼
                    Button {
                        print("설정 눌림")
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }

                    // 시작 버튼 (가운데, 크게)
                    Button {
                        showWalkRecord = true   // 이동할 페이지
                    } label: {
                        Text("▶︎") // 또는 Image(systemName: "play.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color(red: 1.0, green: 0.5, blue: 0.4)) // #FF7F66
                            .clipShape(Circle())
                            .shadow(radius: 4) // 강조 효과
                    }
                    // 전체 뷰 뜨게 하는 방법
                    .fullScreenCover(isPresented: $showWalkRecord) {
                        WalkRecordView()
                    }

                    // 정보 버튼
                    Button {
                        print("정보 눌림")
                    } label: {
                        Image(systemName: "pause.fill")
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                }
                Button {
                    print("하단 버튼")
                } label: {
                    Text("산책 보기")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.black)
                        .frame(width: 20, height: 1)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(.infinity)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
