//
//  PhotoItem.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import Foundation
import UIKit

struct PhotoItem: Identifiable {
    let id = UUID()
    let fileName: String
    let image: UIImage
}
