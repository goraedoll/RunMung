//
//  DogClassifierView.swift
//  RunMung
//

import SwiftUI
import UIKit
import SwiftData

struct DogClassifierView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [DogProfile]

    @StateObject private var viewModel: DogClassifierViewModel
    @State private var showImagePicker = false
    @State private var showDeleteAlert = false

    // 기본 생성자 + 외부 주입 가능
    init(viewModel: DogClassifierViewModel = DogClassifierViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 이미지 + 정보
                    ZStack {
                        HStack(spacing: 20) {
                            // ✅ 뷰모델 선택 이미지 > DB 저장 이미지 순서로 표시
                            if let image = viewModel.selectedImage ?? profiles.first?.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.coral.opacity(0.4), lineWidth: 4))
                                    .onLongPressGesture(minimumDuration: 1.0) {
                                        showDeleteAlert = true
                                    }
                            } else {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 36))
                                                .foregroundStyle(.secondary)
                                            Text("사진 업로드")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    )
                            }

                            Spacer()

                            // 오른쪽: 정보
                            VStack(alignment: .leading, spacing: 12) {
                                Text("멍구르르")
                                    .font(.headline)

                                HStack(spacing: 24) {
                                    VStack {
                                        Text("애착점수")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("87")
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                    }
                                    VStack {
                                        Text("산책 거리")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("12.4 km")
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                    }
                                    VStack {
                                        Text("좋아요")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Text("12")
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                    .onTapGesture { showImagePicker = true }
                    .alert("프로필 사진 초기화", isPresented: $showDeleteAlert) {
                        Button("삭제", role: .destructive) {
                            // ViewModel 비우고 DB도 비우기
                            viewModel.deleteProfileImage()
                            if let profile = profiles.first {
                                profile.profileImageData = nil
                                try? context.save()
                            }
                        }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text("프로필 사진을 초기화하시겠습니까?")
                    }

                    // 애착 점수 평가 화면 이동
                    NavigationLink(
                        destination: AttachmentScoreView(
                            viewModel: AttachmentScoreViewModel(),
                            profileViewModel: viewModel
                        )
                    ) {
                        Text("애착점수 평가하기")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.coral.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    // 강아지 종류 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("강아지 종류")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            TextField("AI로 입력됩니다", text: $viewModel.breedResult)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                            // ✅ selectedImage OR DB profileImage 가 있으면 버튼 표시
                            if (viewModel.selectedImage ?? profiles.first?.profileImage) != nil {
                                Button(action: { viewModel.classifyDog() }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.coral.opacity(0.9))
                                            .frame(height: 56)

                                        if viewModel.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("AI")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                    }


                    // 기본 정보 카드 (AttachmentScoreView와 통일된 스타일)
                    if let profile = profiles.first {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("⚙️ 기본 정보")
                                .font(.headline)
                                .padding(.leading)

                            pickerCard(
                                title: "성별",
                                selection: Binding(
                                    get: { profile.gender },
                                    set: { profile.gender = $0 }
                                ),
                                options: ["M", "F"]
                            )

                            toggleCard(
                                title: "중성화 여부",
                                isOn: Binding(
                                    get: { profile.isNeutered },
                                    set: { profile.isNeutered = $0 }
                                )
                            )

                            stepperCard(
                                title: "나이",
                                value: Binding(
                                    get: { profile.age },
                                    set: { profile.age = $0 }
                                ),
                                range: 0...20,
                                unit: "세"
                            )

                            pickerCard(
                                title: "체중 상태",
                                selection: Binding(
                                    get: { profile.weightState },
                                    set: { profile.weightState = $0 }
                                ),
                                options: ["저체중", "정상", "과체중"]
                            )

                            Spacer(minLength: 40)
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
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: Binding(
                    get: { viewModel.selectedImage },
                    set: { newImage in
                        guard let img = newImage else { return }
                        // ViewModel 업데이트
                        viewModel.saveProfileImage(img)
                        // DB 저장 (없으면 생성)
                        if let profile = profiles.first {
                            profile.profileImageData = img.pngData()
                            try? context.save()
                        } else {
                            let profile = DogProfile(profileImageData: img.pngData())
                            context.insert(profile)
                            try? context.save()
                        }
                    }
                ))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                            .foregroundColor(.secondary)
                    }
                }
            }
            // 최초 진입 시 프로필 없으면 하나 생성
            .task {
                if profiles.isEmpty {
                    context.insert(DogProfile())
                    try? context.save()
                }
            }
        }
    }
}

// MARK: - Subviews (AttachmentScoreView와 동일한 카드 스타일)

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

// MARK: - UIKit ImagePicker Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}


// MARK: - Preview
struct DogClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DogClassifierView()
        }
        .modelContainer(for: [DogProfile.self], inMemory: true)
    }
}
