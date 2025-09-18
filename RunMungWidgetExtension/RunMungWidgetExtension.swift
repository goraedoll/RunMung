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
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text("🐶 런멍")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                if context.state.isPaused {
                    Text(formatTime(context.state.elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let startDate = context.state.startDate {
                    Text(startDate, style: .timer)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

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
                        if context.state.isPaused {
                            Text(formatTime(context.state.elapsedTime))
                                .font(.title3).bold()
                        } else if let startDate = context.state.startDate {
                            Text(startDate, style: .timer)
                                .font(.title3).bold()
                        }
                    }
                },
                compactLeading: {
                    if context.state.isPaused {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.caption2)
                            .frame(width: 40)
                    } else if let startDate = context.state.startDate {
                        Text(startDate, style: .timer)
                            .font(.caption2)
                            .frame(width: 40)
                    }
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

    // 🔹 Helper 함수: 초 → "MM:SS" 또는 "HH:MM:SS"
    private func formatTime(_ elapsed: TimeInterval) -> String {
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        return hours > 0
        ? String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        : String(format: "%02d:%02d", minutes, seconds)
    }
}
