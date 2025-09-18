//
//  RecordListView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI

struct RecordListView: View {
    let records: [RunRecord]

    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        List {
            ForEach(records, id: \.id) { record in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(String(format: "%.2f", record.distance)) km")
                            .font(.headline)
                            .foregroundColor(.coral)
                    }
                    HStack {
                        Text("페이스: \(record.pace)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("시간: \(formatElapsed(record.elapsedTime))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("모든 기록")
    }
}
