//
//  RecordListView.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import SwiftUI
import SwiftData

struct RecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RunRecord.date, order: .reverse) private var records: [RunRecord]
    
    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        for index in offsets {
            let record = records[index]
            modelContext.delete(record)   // ✅ DB에서 삭제
        }
    }
    
    var body: some View {
        List {
            ForEach(records) { record in
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
            .onDelete(perform: deleteRecord)   // ✅ 스와이프 후 삭제 버튼 누르면 바로 삭제
        }
        .navigationTitle("모든 기록")
    }
}

