//
//  RunMungWidgetExtensionBundle.swift
//  RunMungWidgetExtension
//
//  Created by 고래돌 on 9/18/25.
//

import WidgetKit
import SwiftUI

@main
struct RunMungWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivity()   // 여기서 원하는 위젯 등록
    }
}
