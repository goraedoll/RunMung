//
//  AttachmentScoreManager.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import SwiftUI

class AttachmentScoreManager: ObservableObject {
    static let shared = AttachmentScoreManager() // ✅ 싱글톤

    @Published var score: Int = 93
}
