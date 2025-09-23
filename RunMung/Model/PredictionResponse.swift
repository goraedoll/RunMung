//
//  PredictionResponse.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation

// MARK: - API Response Model
struct PredictionResponse: Codable, Identifiable, Equatable {
    let id = UUID()
    let prediction: Int
    let probabilities: [Double]
    let classes: [Int]

    private enum CodingKeys: String, CodingKey {
        case prediction, probabilities, classes
    }
}
