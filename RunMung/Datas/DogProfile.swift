//
//  DogProfile.swift
//  RunMung
//

import SwiftData
import UIKit

@Model
class DogProfile {
    var gender: String
    var isNeutered: Bool
    var ageRange: String
    var age: Int
    var environment: String
    var size: String
    var weightState: String
    var profileImageData: Data?

    init(
        gender: String = "M",
        isNeutered: Bool = false,
        ageRange: String = "성년",
        age: Int = 2,
        environment: String = "실내",
        size: String = "소형",
        weightState: String = "정상",
        profileImageData: Data? = nil
    ) {
        self.gender = gender
        self.isNeutered = isNeutered
        self.ageRange = ageRange
        self.age = age
        self.environment = environment
        self.size = size
        self.weightState = weightState
        self.profileImageData = profileImageData
    }
}

extension DogProfile {
    var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
}
