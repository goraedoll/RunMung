import SwiftUI
import SwiftData

struct AttachmentScoreView: View {
    @ObservedObject var viewModel: AttachmentScoreViewModel
    @ObservedObject var profileViewModel: DogClassifierViewModel
    
    @Environment(\.modelContext) private var context
    @Query private var profiles: [DogProfile]

    init(viewModel: AttachmentScoreViewModel,
         profileViewModel: DogClassifierViewModel) {
        self.viewModel = viewModel
        self.profileViewModel = profileViewModel
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 28) {
                        // 상단 프로필 섹션
                        VStack(spacing: 12) {
                            if let image = profileViewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.coral.opacity(0.4), lineWidth: 4))
                            } else {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 36))
                                                .foregroundStyle(.secondary)
                                            Text("사진 없음")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    )
                            }

                            Text("🐶 AI 애정 점수!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.coral)
                        }
                        .padding(.top, 20)

                        // ✅ 품종 (읽기 전용)
                        infoCard(title: "품종", value: profileViewModel.breedResult)

                        // -------------------------
                        // 📋 주요 정보
                        // -------------------------
                        VStack(alignment: .leading, spacing: 16) {
                            Text("📋 일일 입력 정보")
                                .font(.headline)
                                .padding(.leading)

                            pickerCard(title: "배변상태", selection: $viewModel.defecation,
                                       options: Array(viewModel.defecationMap.keys))

                            pickerCard(title: "질병 여부", selection: $viewModel.disease,
                                       options: Array(viewModel.diseaseMap.keys))

                            // ✅ 1회 식사량 (30g 단위 환산)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("1회 식사량")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Stepper(value: $viewModel.foodAmount, in: 1...8) {
                                    let grams = viewModel.foodAmount * 30
                                    Text("\(viewModel.foodAmount) 단위 (\(grams) g)")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        }

                        // -------------------------
                        // ⚙️ 기본 정보
                        // -------------------------
                        if let profile = profiles.first {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("⚙️ 기본 정보")
                                    .font(.headline)
                                    .padding(.leading)

                                pickerCard(title: "성별", selection: Binding(
                                    get: { profile.gender },
                                    set: { profile.gender = $0 }
                                ), options: ["M","F"])

                                toggleCard(title: "중성화 여부", isOn: Binding(
                                    get: { profile.isNeutered },
                                    set: { profile.isNeutered = $0 }
                                ))

                                pickerCard(title: "연령대", selection: Binding(
                                    get: { profile.ageRange },
                                    set: { profile.ageRange = $0 }
                                ), options: Array(viewModel.ageRangeMap.keys))

                                stepperCard(title: "나이", value: Binding(
                                    get: { profile.age },
                                    set: { profile.age = $0 }
                                ), range: 0...20, unit: "세")

                                pickerCard(title: "생활환경", selection: Binding(
                                    get: { profile.environment },
                                    set: { profile.environment = $0 }
                                ), options: Array(viewModel.environmentMap.keys))

                                pickerCard(title: "크기", selection: Binding(
                                    get: { profile.size },
                                    set: { profile.size = $0 }
                                ), options: Array(viewModel.sizeMap.keys))

                                pickerCard(title: "체중 상태", selection: Binding(
                                    get: { profile.weightState },
                                    set: { profile.weightState = $0 }
                                ), options: Array(viewModel.weightMap.keys))
                            }
                        } else {
                            Button("강아지 기본정보 만들기") {
                                let newProfile = DogProfile(
                                    gender: "M",
                                    isNeutered: false,
                                    ageRange: "성년",
                                    age: 1,
                                    environment: "실내",
                                    size: "소형",
                                    weightState: "정상"
                                )
                                try? context.save()
                            }                            .padding()
                        }

                        // -------------------------
                        // 데이터 미리보기
                        // -------------------------
                        VStack(alignment: .leading, spacing: 6) {
                            Text("📦 서버 전송 데이터 (미리보기)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.coral)

                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(viewModel.previewJSON())
                                    .font(.caption.monospaced())
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text("⚠️ \(error)")
                                .foregroundColor(.red)
                                .padding()
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal)
                }

                // 하단 버튼
                Button(action: viewModel.predictExercise) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.coral)
                            .frame(height: 56)
                            .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("애정 점수 예측하기")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom, 12)
            }

            // 결과 Bottom Sheet
            if let result = viewModel.predictionResult {
                ResultBottomSheet(result: result) {
                    withAnimation {
                        viewModel.predictionResult = nil
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { // ✅ 최초 1회만 실행
            if profiles.isEmpty {
                let newProfile = DogProfile() // 기본값으로
                context.insert(newProfile)
                try? context.save()
            }
        }
    }
}


// MARK: - Subviews
private func pickerCard(title: String, selection: Binding<String>, options: [String]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title).font(.subheadline).foregroundColor(.secondary)
        Picker(title, selection: selection) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
}

private func stepperCard(title: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title).font(.subheadline).foregroundColor(.secondary)
        Stepper(value: value, in: range) {
            Text("\(value.wrappedValue)\(unit)")
        }
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
}

private func toggleCard(title: String, isOn: Binding<Bool>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Toggle(isOn: isOn) { Text(title) }
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
}

// 정보 카드 (이중 배경 스타일)
private func infoCard(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)

        Text(value.isEmpty ? "값 없음" : value)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
    )
}


struct AttachmentScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AttachmentScoreView(
                viewModel: AttachmentScoreViewModel(),
                profileViewModel: DogClassifierViewModel()
            )
        }
        .modelContainer(for: [DogProfile.self], inMemory: true) // 프리뷰
    }
}
