//
//  HomeHeaderView.swift
//  RunMung
//

import SwiftUI

struct HomeHeaderView: View {
    var onFavoriteTapped: () -> Void = {}
    var profileImage: Image? = nil   // 추후 DB에서 불러오도록 확장 가능
    
    var body: some View {
        HStack {
            // 왼쪽: 프로필 아이콘
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 오른쪽 즐겨찾기 버튼
            Button(action: onFavoriteTapped) {
                Image(systemName: "star.fill") // 즐겨찾기 상태면 star.fill
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
    }
}

#Preview {
    HomeHeaderView(onFavoriteTapped: { print("⭐️ 즐겨찾기 눌림") })
}
