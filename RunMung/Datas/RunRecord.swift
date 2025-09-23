//
//  RunRecord.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import Foundation
import SwiftData

@Model
class RunRecord {
    var date: Date
    var distance: Double
    var elapsedTime: Double
    var pace: String
    
    @Relationship(deleteRule: .cascade) var routePoints: [RunLocation] = []
    
    init(date: Date, distance: Double, elapsedTime: Double, pace: String) {
        self.date = date
        self.distance = distance
        self.elapsedTime = elapsedTime
        self.pace = pace
    }
}
