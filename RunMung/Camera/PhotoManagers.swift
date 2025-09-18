//
//  PhotoObject.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI

/// 사진용 시간 상태 (달리기 기록 저장용 스냅샷)
class PhotoManager: ObservableObject {
    @Published var formattedTime: String = "--:--:--"
    @Published var elapsedTime: TimeInterval = 0
}

/// 사진용 거리/페이스 상태 (달리기 기록 저장용 스냅샷)
class PhotoDisplayManager: ObservableObject {
    @Published var totalDistance: Double = 0.0
    @Published var pace: String = "--'--\""
}
