//
//  Item.swift
//  RunMung
//
//  Created by 고래돌 on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
