//
//  HomeActiveButtonView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//
import SwiftUI

public struct HomeActiveButtonView: View {
    public var body: some View {
        VStack {
            HStack(spacing: 28) {
                // 설정 버튼
                Button {
                    print("설정 눌림")
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 8)
                }

                // 시작 버튼 (가운데, 크게)
                Button {
                    print("시작 눌림")
                } label: {
                    Text("▶︎") // 또는 Image(systemName: "play.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color(red: 1.0, green: 0.5, blue: 0.4)) // #FF7F66
                        .clipShape(Circle())
                        .shadow(radius: 4) // 강조 효과
                }

                // 정보 버튼
                Button {
                    print("정보 눌림")
                } label: {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 8)
                }
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
