//
//  PhotoItem.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import Foundation
import UIKit

struct PhotoItem: Identifiable, Hashable {
    let id = UUID()             // Identifiable
    let fileName: String
    let image: UIImage

    // UIImage는 직접 Hashable이 아니므로 fileName만 비교 기준으로 둡니다
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.fileName == rhs.fileName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
    }
}
