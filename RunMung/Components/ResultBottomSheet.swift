import SwiftUI

struct ResultBottomSheet: View {
    let result: PredictionResponse
    let breed: String
    let onClose: () -> Void
    
    @ObservedObject private var scoreManager = AttachmentScoreManager.shared
    @StateObject private var guideVM = DogGuideViewModel()

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                // 상단 캡슐
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                // 타이틀
                Text("✨ 예측 결과")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // 애착 점수
                Text("애착 점수: \(scoreManager.score)점")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.coral)

                // 메인 결과
                Text("추천 운동 강도: \(result.prediction) 단계")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.coral)

                // 확률 막대 + 정확도 표시
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(result.classes.enumerated()), id: \.offset) { idx, cls in
                        let prob = result.probabilities[idx]
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("단계 \(cls)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text(String(format: "%.1f%%", prob * 100))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(cls == result.prediction ? Color.coral : Color.gray.opacity(0.3))
                                    .frame(width: geo.size.width * CGFloat(prob), height: 8)
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // 강아지 가이드 섹션
                if guideVM.isLoading {
                    ProgressView("강아지 가이드 불러오는 중...")
                        .padding()
                } else if let guide = guideVM.guide {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🐶 \(guide.breedName) 가이드")
                        Text("산책 가이드: \(guide.walkingGuide)")
                        Text("놀이 가이드: \(guide.playGuide)")
                        Text("추가 팁: \(guide.additionalTips)")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                } else if let error = guideVM.errorMessage {
                    Text("에러: \(error)")
                        .foregroundColor(.red)
                }

                // 닫기 버튼
                Button("닫기") {
                    withAnimation(.spring()) { // ✅ 닫을 때만 애니메이션 적용
                        onClose()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.coral)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            // ✅ 뷰가 나타날 때 API 호출
            .onAppear {
                Task {
                    await guideVM.loadGuide(
                        breed: breed,
                        workoutLevel: "\(result.prediction)"
                    )
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity)) // ✅ 자연스러운 전환
    }
}
