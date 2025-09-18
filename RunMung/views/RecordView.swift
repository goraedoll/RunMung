//
//  RecordView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//
import SwiftUI
import SwiftData
import Charts   // iOS 16+ Charts 프레임워크

struct RecordView: View {
    @Query(sort: \RunRecord.date, order: .reverse)
    private var records: [RunRecord]   // SwiftData에서 기록 불러오기
    
    @State private var selectedFilter: String = "주"
    
    private let filters = ["주", "월", "년", "전체"]
    
    var body: some View {
        VStack(spacing: 0) {
            HomeHeaderView()
            HomeTitleView(text: "기록")
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ✅ 필터 버튼
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedFilter == filter ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedFilter == filter ? Color.coral : Color(.systemGray5))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // ✅ 요약 카드
                    HStack(spacing: 12) {
                        SummaryCard(title: "총 산책 횟수", value: "\(filteredRecords.count)회")
                        SummaryCard(title: "평균 페이스", value: avgPace())
                        SummaryCard(title: "총 시간", value: totalElapsed())
                    }
                    .padding(.horizontal)
                    
                    // ✅ 그래프 카드
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(selectedFilter) 활동 그래프")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Chart(filteredRecords) { record in
                            BarMark(
                                x: .value("날짜", record.date.formatted(date: .abbreviated, time: .omitted)),
                                y: .value("거리", record.distance)
                            )
                            .foregroundStyle(Color.coral.gradient)
                            .cornerRadius(6)
                        }
                        .frame(height: 220)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // ✅ 기록 리스트 (카드 스타일)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(filteredRecords) { record in
                            VStack(alignment: .leading, spacing: 8) {
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
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
            }
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - Helper functions
    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func avgPace() -> String {
        guard !filteredRecords.isEmpty else { return "--'--\"" }
        return filteredRecords.last?.pace ?? "--'--\""
    }
    
    private func totalElapsed() -> String {
        let total = filteredRecords.map { Int($0.elapsedTime) }.reduce(0, +)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // ✅ 선택된 필터에 따라 데이터 가공
    private var filteredRecords: [RunRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case "주":
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                return records.filter { $0.date >= weekAgo }
            }
        case "월":
            if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                return records.filter { $0.date >= monthAgo }
            }
        case "년":
            if let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) {
                return records.filter { $0.date >= yearAgo }
            }
        default: // 전체
            return records
        }
        return records
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


#Preview("기록 화면") {
    RecordView()
        .environmentObject(DistanceTracker())
        .environmentObject(TimerManager())
        .modelContainer(for: RunRecord.self, inMemory: true)
}

#Preview("기록 화면 (한 달 샘플)") {
    // 프리뷰 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: RunRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 샘플 데이터 삽입 (최근 30일)
    let context = container.mainContext
    let calendar = Calendar.current
    
    for i in 0..<30 { // 최근 30일치 기록
        let date = calendar.date(byAdding: .day, value: -i, to: Date())!
        let record = RunRecord(
            date: date,
            distance: Double.random(in: 2...12), // 2~12km
            elapsedTime: Double.random(in: 1200...7200), // 20분~2시간
            pace: String(format: "%d'%02d\"", Int.random(in: 4...7), Int.random(in: 0...59)) // 대충 4'00"~7'59"
        )
        context.insert(record)
    }
    
    return RecordView()
        .environmentObject(DistanceTracker())
        .environmentObject(TimerManager())
        .modelContainer(container) // 직접 만든 컨테이너 주입
}


#Preview("기록 화면 (일주일 샘플)") {
    // 프리뷰 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: RunRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 샘플 데이터 삽입
    let context = container.mainContext
    let calendar = Calendar.current
    
    for i in 0..<6 { // 최근 7일치 기록
        let date = calendar.date(byAdding: .day, value: -i, to: Date())!
        let record = RunRecord(
            date: date,
            distance: Double.random(in: 2...10), // 2~10km
            elapsedTime: Double.random(in: 900...5400), // 15분~90분
            pace: String(format: "%d'%02d\"", Int.random(in: 4...6), Int.random(in: 0...59)) // 대충 4'00"~6'59"
        )
        context.insert(record)
    }
    
    return RecordView()
        .environmentObject(DistanceTracker())
        .environmentObject(TimerManager())
        .modelContainer(container) // 직접 만든 컨테이너 주입
}

#Preview("기록 화면 (1일치 샘플)") {
    // 프리뷰 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: RunRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 샘플 데이터 1개 삽입
    let context = container.mainContext
    let record = RunRecord(
        date: Date(),
        distance: 5.2,               // 예: 5.2km
        elapsedTime: 1800,           // 예: 30분 (1800초)
        pace: "5'45\""               // 예: 5분 45초/km
    )
    context.insert(record)
    
    return RecordView()
        .environmentObject(DistanceTracker())
        .environmentObject(TimerManager())
        .modelContainer(container) // 직접 만든 컨테이너 주입
}
