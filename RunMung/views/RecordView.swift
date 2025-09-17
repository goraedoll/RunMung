//
//  RecordView.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import SwiftUI
import Charts   // iOS 16+ Charts 프레임워크

extension Color {
    static let coral = Color(red: 1.0, green: 0.5, blue: 0.4) // HEX: #FF7F66
}

struct RecordView: View {
    @State private var selectedFilter: String = "주"
    
    private let filters = ["주", "월", "년", "전체"]
    
    struct RunData: Identifiable {
        let id = UUID()
        let date: String
        let distance: Double
    }
    
    private let sampleRuns: [RunData] = [
        .init(date: "월", distance: 3.2),
        .init(date: "화", distance: 5.0),
        .init(date: "수", distance: 2.5),
        .init(date: "목", distance: 4.1),
        .init(date: "금", distance: 6.0),
        .init(date: "토", distance: 7.2),
        .init(date: "일", distance: 0.0)
    ]
    
    var body: some View {
        VStack {
            HomeHeaderView()
            HomeTitleView(text: "기록")
            
            NavigationView {
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
                            SummaryCard(title: "총 달린 횟수", value: "24회")
                            SummaryCard(title: "평균 페이스", value: "5'20\"/km")
                            SummaryCard(title: "총 시간", value: "12h 40m")
                        }
                        .padding(.horizontal)
                        
                        // ✅ 그래프 카드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(selectedFilter) 활동 그래프")
                                .font(.headline)
                            
                            Chart(sampleRuns) { run in
                                BarMark(
                                    x: .value("요일", run.date),
                                    y: .value("거리", run.distance)
                                )
                                .foregroundStyle(Color.coral.gradient)
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white) // 흰색 카드
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                }
                .background(Color(.systemGray6)) // 전체 배경 → SettingView랑 맞춤
            }
        }
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white) // ✅ 카드 흰색
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MainTabView()
}

