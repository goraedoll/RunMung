//
//  SampleDataLoader.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation
import SwiftData

struct SampleDataLoader {
    static func insertSampleRuns(context: ModelContext) {
        let calendar = Calendar.current
        let dates = [
            calendar.date(from: DateComponents(year: 2025, month: 9, day: 22))!,
            calendar.date(from: DateComponents(year: 2025, month: 9, day: 23))!,
            calendar.date(from: DateComponents(year: 2025, month: 9, day: 24))!,
            calendar.date(from: DateComponents(year: 2025, month: 9, day: 25))!
        ]
        
        for date in dates {
            // 날짜는 고정, 값은 랜덤
            let distance = Double.random(in: 3...8)          // 3~8 km
            let elapsedTime = Double.random(in: 1500...3600) // 25분~60분
            let paceMinutes = Int.random(in: 4...7)
            let paceSeconds = Int.random(in: 0...59)
            let pace = String(format: "%d'%02d\"", paceMinutes, paceSeconds)
            
            let record = RunRecord(
                date: date,              // 날짜는 고정
                distance: distance,      // 값은 랜덤
                elapsedTime: elapsedTime,
                pace: pace
            )
            context.insert(record)
        }
        try? context.save()
    }
}

