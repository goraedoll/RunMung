//
//  DogGuideModels.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation

// 서버 요청 모델
struct DogGuideRequest: Codable {
    let breeds: String
    let workoutLevel: String   // Swift에서는 소문자

    enum CodingKeys: String, CodingKey {
        case breeds
        case workoutLevel = "WorkoutLevel" // 서버 JSON은 대문자 W
    }
}

// 서버 응답 모델
struct DogGuideResponse: Codable {
    let breedName: String
    let workoutLevel: String
    let walkingGuide: String
    let playGuide: String
    let additionalTips: String

    enum CodingKeys: String, CodingKey {
        case breedName = "breed_name"
        case workoutLevel = "workout_level"
        case walkingGuide = "walking_guide"
        case playGuide = "play_guide"
        case additionalTips = "additional_tips"
    }
}
