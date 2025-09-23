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
    
    @State private var showDeleteAllAlert = false
    
    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        for index in offsets {
            let record = records[index]
            modelContext.delete(record)
        }
        try? modelContext.save()
    }
    
    private func deleteAllRecords() {
        for record in records {
            modelContext.delete(record)
        }
        try? modelContext.save()
    }
    
    private func insertSampleData() {
        SampleDataLoader.insertSampleRuns(context: modelContext)
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
            .onDelete(perform: deleteRecord)
        }
        .navigationTitle("모든 기록")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // 샘플 데이터 추가
                Button(action: insertSampleData) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.coral)
                }
                // 모든 기록 삭제
                Button(role: .destructive) {
                    showDeleteAllAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                }
            }
        }
        .alert("모든 기록 삭제", isPresented: $showDeleteAllAlert) {
            Button("삭제", role: .destructive) {
                deleteAllRecords()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("정말 모든 기록을 삭제하시겠습니까?")
        }
    }
}
