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
    
    // ✅ 선택된 필터 범위의 RunRecord만 반환
    private var filteredRunRecords: [RunRecord] {
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedFilter {
        case "주":
            var iso = Calendar(identifier: .iso8601)
            iso.timeZone = calendar.timeZone
            let startOfWeek = iso.date(from: iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let endOfWeek = iso.date(byAdding: .day, value: 6, to: startOfWeek)!
            return records.filter { $0.date >= startOfWeek && $0.date <= endOfWeek }
            
        case "월":
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            let range = calendar.range(of: .day, in: .month, for: today)!
            let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!
            return records.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
            
        case "년":
            let year = calendar.component(.year, from: today)
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
            return records.filter { $0.date >= startOfYear && $0.date <= endOfYear }
            
        case "전체":
            return records
            
        default:
            return records
        }
    }

    var body: some View {
        NavigationStack{
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
                        
                        // ✅ 요약 카드 (필터 기준 값 표시)
                        HStack(spacing: 12) {
                            SummaryCard(title: "총 산책 횟수", value: "\(filteredRunRecords.count)회")
                            SummaryCard(title: "평균 페이스", value: avgPace(records: filteredRunRecords))
                            SummaryCard(title: "총 시간", value: totalElapsed(records: filteredRunRecords))
                        }
                        .padding(.horizontal)

                        
                        // ✅ 그래프 카드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(selectedFilter) 활동 그래프")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Chart(displayedRecords, id: \.id) { record in
                                BarMark(
                                    x: .value("날짜", record.label),
                                    y: .value("거리", record.distance)
                                )
                                .foregroundStyle(Color.coral.gradient)
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading) {
                                    AxisTick()
                                    AxisValueLabel()
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // ✅ 최근 기록 섹션
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("최근 기록")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                NavigationLink(destination: RecordListView(records: records)) {
                                    Text("더보기")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            ForEach(records.prefix(4), id: \.id) { record in
                                VStack(alignment: .leading, spacing: 8) {
                                    // 상단 날짜 + 거리
                                    HStack {
                                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("\(String(format: "%.2f", record.distance)) km")
                                            .font(.headline)
                                            .foregroundColor(.coral)
                                    }
                                    
                                    // 하단 페이스 + 시간
                                    HStack {
                                        Label(record.pace, systemImage: "pawprint.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Label(formatElapsed(record.elapsedTime), systemImage: "clock")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                }
                .background(Color(.systemGray6))
            }
            
        }
    }
    
    // MARK: - Helper functions
    private func formatElapsed(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // ✅ 평균 페이스 (필터 기준)
    private func avgPace(records: [RunRecord]) -> String {
        guard !records.isEmpty else { return "--'--\"" }
        let valid = records.filter { $0.distance > 0 }
        return valid.last?.pace ?? "--'--\""
    }

    // ✅ 총 시간 (필터 기준)
    private func totalElapsed(records: [RunRecord]) -> String {
        let total = records.map { Int($0.elapsedTime) }.reduce(0, +)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // ✅ 표시용 데이터 (주/월 → 일 단위, 년 → 월 단위(평균), 전체 → 연 단위)
    private var displayedRecords: [DisplayRecord] {
        switch selectedFilter {
        case "주": return makeWeeklyRecords()
        case "월": return makeMonthlyRecords()
        case "년": return makeYearlyRecords()
        case "전체": return makeTotalRecords()
        default: return []
        }
    }

    // MARK: - 주 단위 데이터 (월~일, 하루씩)
    private func makeWeeklyRecords() -> [DisplayRecord] {
        let calendar = Calendar.current
        var iso = Calendar(identifier: .iso8601)
        iso.timeZone = calendar.timeZone
        
        let today = Date()
        guard let startOfWeek = iso.date(from: iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let endOfWeek = iso.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return []
        }
        
        let filled = filledRecords(range: (startOfWeek, endOfWeek))
        
        return filled.map { rec in
            let label = rec.date.formatted(.dateTime.weekday(.abbreviated))
            return DisplayRecord(date: rec.date, label: label, distance: rec.distance)
        }
    }

    // MARK: - 월 단위 데이터 (1일~말일, 하루씩)
    private func makeMonthlyRecords() -> [DisplayRecord] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let range = calendar.range(of: .day, in: .month, for: today),
              let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth) else {
            return []
        }
        
        let filled = filledRecords(range: (startOfMonth, endOfMonth))
        
        return filled.map { rec in
            // 숫자만 표시
            let day = calendar.component(.day, from: rec.date)
            let label = "\(day)"   // "1", "2", "3" ...
            return DisplayRecord(date: rec.date, label: label, distance: rec.distance)
        }
    }


    // MARK: - 연 단위 데이터 (1월~12월, 월평균)
    private func makeYearlyRecords() -> [DisplayRecord] {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return []
        }
        
        let filled = filledRecords(range: (startOfYear, endOfYear))
        let grouped = Dictionary(grouping: filled) { rec in
            calendar.component(.month, from: rec.date)
        }
        
        return (1...12).map { month in
            let monthRecords = grouped[month] ?? []
            let avg = monthRecords.isEmpty ? 0.0 :
                monthRecords.map { $0.distance }.reduce(0, +) / Double(monthRecords.count)
            
            let label = "\(month)"
            let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            
            return DisplayRecord(date: date, label: label, distance: avg)
        }
    }

    // MARK: - 전체 데이터 (연 단위 평균)
    private func makeTotalRecords() -> [DisplayRecord] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { rec in
            calendar.component(.year, from: rec.date)
        }
        let years = grouped.keys.sorted()
        
        return years.map { year in
            let yearRecords = grouped[year] ?? []
            let avg = yearRecords.isEmpty ? 0.0 :
                yearRecords.map { $0.distance }.reduce(0, +) / Double(yearRecords.count)
            
            let label = "\(year)년"
            let date = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            
            return DisplayRecord(date: date, label: label, distance: avg)
        }
    }

    // ✅ 범위 안 모든 날짜 생성
    private func datesInRange(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        let calendar = Calendar.current
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    // ✅ 날짜별 기록 있으면 그대로, 없으면 0km 레코드 생성
    private func filledRecords(range: (start: Date, end: Date)) -> [RunRecord] {
        let allDates = datesInRange(from: range.start, to: range.end)
        
        return allDates.map { date in
            if let existing = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                return existing
            } else {
                return RunRecord(date: date, distance: 0.0, elapsedTime: 0, pace: "--'--\"")
            }
        }
    }
}

// ✅ 차트 표시용 구조체
struct DisplayRecord: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let label: String
    let distance: Double
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
#Preview("기록 화면 1년 샘플)") {
    // 프리뷰 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: RunRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 샘플 데이터 삽입 (최근 30일)
    let context = container.mainContext
    let calendar = Calendar.current
    
    for i in 0..<365 { // 최근 30일치 기록
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
