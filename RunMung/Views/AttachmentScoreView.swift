import SwiftUI

struct AttachmentScoreView: View {
    @StateObject private var viewModel = AttachmentScoreViewModel()
    @StateObject private var profileViewModel = DogClassifierViewModel()

    // ✅ DogClassifierView에서 전달되는 초기 견종
    let initialBreedKorean: String?
    let initialBreedCode: String?

    init(initialBreedKorean: String? = nil, initialBreedCode: String? = nil) {
        self.initialBreedKorean = initialBreedKorean
        self.initialBreedCode = initialBreedCode
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 28) {
                        // ✅ 상단 프로필 섹션
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
                        infoCard(title: "품종", value: viewModel.breed)
                            .onAppear {
                                if let breed = initialBreedKorean,
                                   viewModel.breedMap.keys.contains(breed) {
                                    viewModel.breed = breed
                                }
                            }

                        // -------------------------
                        // 📋 주요 입력 그룹
                        // -------------------------
                        VStack(alignment: .leading, spacing: 16) {
                            Text("📋 주요 정보")
                                .font(.headline)
                                .padding(.leading)

                            pickerCard(title: "생활환경", selection: $viewModel.environment,
                                       options: Array(viewModel.environmentMap.keys))
                            pickerCard(title: "배변상태", selection: $viewModel.defecation,
                                       options: Array(viewModel.defecationMap.keys))
                            pickerCard(title: "질병 여부", selection: $viewModel.disease,
                                       options: Array(viewModel.diseaseMap.keys))
                            pickerCard(title: "크기", selection: $viewModel.size,
                                       options: Array(viewModel.sizeMap.keys))
                            pickerCard(title: "체중 상태", selection: $viewModel.weightState,
                                       options: Array(viewModel.weightMap.keys))
                        }

                        // -------------------------
                        // ⚙️ 부가 입력 그룹
                        // -------------------------
                        VStack(alignment: .leading, spacing: 16) {
                            Text("⚙️ 부가 정보")
                                .font(.headline)
                                .padding(.leading)

                            pickerCard(title: "성별", selection: $viewModel.gender, options: ["M","F"])
                            toggleCard(title: "중성화 여부", isOn: $viewModel.isNeutered)
                            pickerCard(title: "연령대", selection: $viewModel.ageRange,
                                       options: Array(viewModel.ageRangeMap.keys))
                            stepperCard(title: "나이", value: $viewModel.age, range: 0...20, unit: "세")
                        }

                        // -------------------------
                        // 식사 관련 입력
                        // -------------------------
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🍽️ 식사 정보")
                                .font(.headline)
                                .padding(.leading)

                            stepperCard(title: "식사 횟수", value: $viewModel.foodCount, range: 1...4, unit: "회")
                            stepperCard(title: "1회 식사량", value: $viewModel.foodAmount, range: 1...8, unit: "단위")
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
                            Text("추천 운동 강도 예측하기")
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
                initialBreedKorean: "진도",
                initialBreedCode: "JIN"
            )
        }
    }
}
