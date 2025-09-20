//
//  PhotoDetailView.swift
//  RunMung
//
//  Created by 고래돌 on 9/20/25.
//
import SwiftUI

struct PhotoDetailView: View {
    let photo: PhotoItem
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Image(uiImage: photo.image)
                .resizable()
                .scaledToFit()
                .padding()
        }
    }
}

