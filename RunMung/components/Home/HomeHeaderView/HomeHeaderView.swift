//
//  HomeHeaderView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
            
            Spacer()
            
            // 오른쪽 즐겨찾기 아이콘
            Button(action: {
                print("즐겨찾기")
            }) {
                Image(systemName: "star")
                    .font(.system(size:20, weight: .bold))
                    .foregroundColor(.gray,)
            }
        }
        .padding(16)
        .frame(height: 60)
    }
}

#Preview {
    ContentView()
}
