//
//  RunLocation.swift
//  RunMung
//
//  Created by 고래돌 on 9/22/25.
//

import Foundation
import SwiftData

@Model
class RunLocation {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var speed: Double
    
    init(latitude: Double, longitude: Double, timestamp: Date, speed: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.speed = speed
    }
}
