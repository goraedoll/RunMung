//
//  ContentView.swift
//  RunMung
//
//  Created by 고래돌 on 9/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HomeMapView()
                    .padding(.top, 160)
            }
            VStack(spacing: 4) {
                HomeHeaderView()
                Text("🐶 RunMung")
                    .font(.system(size: 32, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                HomeSlidingView()
                Spacer()
                HomeActiveButtonView()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}


#Preview {
    ContentView()
}
