//
//  DogClassifierView.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import SwiftUI
import UIKit

struct DogClassifierView: View {
    @StateObject private var viewModel: DogClassifierViewModel
    @State private var showImagePicker = false
    @State private var showDeleteAlert = false
    
    // 기본 생성자 + 외부 주입 가능
    init(viewModel: DogClassifierViewModel = DogClassifierViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                // 프로필 이미지 + 정보
                ZStack {
                    HStack(spacing: 20) {
                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
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
                        viewModel.deleteProfileImage()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("프로필 사진을 초기화하시겠습니까?")
                }
                
                // 애착 점수 평가 화면 이동
                NavigationLink(
                    destination: AttachmentScoreView(
                        initialBreedKorean: viewModel.breedResult,   // 한국어
                        initialBreedCode: viewModel.breedCode        // 코드값
                    )
                ) {
                    Text("애착점수 평가하기")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.coral.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // 강아지 종류 입력창
                VStack(alignment: .leading, spacing: 8) {
                    Text("강아지 종류")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    HStack {
                        TextField("AI로 입력됩니다", text: $viewModel.breedResult)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        
                        if viewModel.selectedImage != nil {
                            Button(action: { viewModel.classifyDog() }) {
                                ZStack {
                                    Text(viewModel.isLoading ? "" : "AI")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.coral.opacity(0.9))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                            }
                            .disabled(viewModel.isLoading)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: Binding(
                    get: { viewModel.selectedImage },
                    set: { newImage in
                        if let img = newImage {
                            viewModel.saveProfileImage(img)
                        }
                    }
                ))
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}



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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}


class MockDogClassifierViewModel: DogClassifierViewModel {
    override init() {
        super.init()
        self.selectedImage = UIImage(systemName: "photo") // 미리보기용 이미지
        self.breedResult = "Pomeranian"
        self.isLoading = false
    }
}



struct DogClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DogClassifierView()
                .previewDisplayName("기본 화면")

            // 👉 MockViewModel을 직접 주입하고 싶다면 init에 넣는 식으로 바꿔야 함
            DogClassifierView()
                .previewDisplayName("샘플 데이터 적용")
        }
    }
}
