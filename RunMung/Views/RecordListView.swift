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
    
    @State private var showDeleteAlert = false        // ✅ Alert 상태
    @State private var pendingDeleteOffsets: IndexSet? // ✅ 삭제할 대상 저장
    
    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func confirmDelete() {
        guard let offsets = pendingDeleteOffsets else { return }
        for index in offsets {
            let record = records[index]
            modelContext.delete(record)   // ✅ DB에서 삭제
        }
        pendingDeleteOffsets = nil
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
            .onDelete { offsets in
                pendingDeleteOffsets = offsets    // ✅ 삭제 보류
                showDeleteAlert = true            // ✅ Alert 표시
            }
        }
        .navigationTitle("모든 기록")
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {
                pendingDeleteOffsets = nil
            }
            Button("삭제", role: .destructive) {
                confirmDelete()
            }
        } message: {
            Text("삭제하면 되돌릴 수 없습니다.")
        }
    }
}
