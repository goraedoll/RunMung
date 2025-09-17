//
//  HomeTitleView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI

struct HomeTitleView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
}
