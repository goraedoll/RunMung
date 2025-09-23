import SwiftUI

struct ResultBottomSheet: View {
    let result: PredictionResponse
    let onClose: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                // 상단 캡슐 (드래그 핸들 느낌)
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                // 타이틀
                Text("✨ 예측 결과")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // 메인 결과
                Text("추천 운동 강도: \(result.prediction) 단계")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.coral) // ✅ coral만 강조

                // 확률 막대 그래프
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(result.classes.enumerated()), id: \.offset) { idx, cls in
                        let prob = result.probabilities[idx]
                        HStack {
                            Text("단계 \(cls)")
                                .frame(width: 70, alignment: .leading)

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(cls == result.prediction ? Color.coral : Color.gray.opacity(0.3)) // ✅ coral만 강조
                                    .frame(width: geo.size.width * CGFloat(prob), height: 10)
                            }

                            Text(String(format: "%.1f%%", prob * 100))
                                .frame(width: 60, alignment: .trailing)
                        }
                        .frame(height: 20)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                // 닫기 버튼
                Button("닫기") {
                    onClose()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.coral) // ✅ coral 단색
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 10)
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: result)
    }
}
