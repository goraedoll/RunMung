//
//  RunMungWidgetExtension.swift
//  RunMungWidgetExtension
//
import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // 🔹 잠금 화면 / 홈 화면 UI
            VStack(spacing: 8) {
                // 상단 러닝 아이콘 + 앱 이름
                HStack(spacing: 6) {
                    Text("🐶 런멍")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                // 메인 타이머
                Text(context.state.startDate, style: .timer)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)

                // 부제목
                Text("런닝 타이머")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.8))
            )

        } dynamicIsland: { context in
            DynamicIsland(
                expanded: {
                    DynamicIslandExpandedRegion(.leading) {
                        Image(systemName: "figure.run.circle.fill")
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        Text(context.state.startDate, style: .timer)
                            .font(.title3).bold()
                    }
                },
                compactLeading: {
                    Text(context.state.startDate, style: .timer)
                        .font(.caption2)       // 훨씬 작게
                        .frame(width: 40)
                },
                compactTrailing: {
                    Image(systemName: "figure.run")
                },
                minimal: {
                    Image(systemName: "figure.run")
                }
            )
        }
    }
}
