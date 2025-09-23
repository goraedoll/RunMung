//
//  DogClassifierViewModel.swift
//  RunMung
//

import SwiftUI
import UIKit

class DogClassifierViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var breedResult: String = ""   // UI 표시용 (한국어)
    @Published var breedCode: String = ""     // ML 서버 전송용
    @Published var isLoading: Bool = false

    // 추가 필드(필요 시 사용)
    @Published var defecation: String = ""
    @Published var size: String = ""
    @Published var ageRange: String = ""
    @Published var neutered: String = ""
    @Published var environment: String = ""
    @Published var disease: String = ""
    @Published var weightState: String = ""
    @Published var gender: String = ""

    // ✅ 품종 매핑
    private let breedMapping: [String: (code: String, korean: String)] = [
        "Poodle": ("POO", "푸들"),
        "Pomeranian": ("POM", "포메라니안"),
        "Alaskan Malamute": ("MAL", "말라뮤트"),
        "Bichon Frise": ("BIC", "비숑프리제"),
        "Chihuahua": ("CHL", "치와와"),
        "Labrador Retriever": ("LAB", "래브라도리트리버"),
        "Jindo": ("JIN", "진돗개")
    ]

    // View에서 DB 저장을 처리하므로, ViewModel은 메모리만 관리
    func saveProfileImage(_ image: UIImage) {
        selectedImage = image
    }

    func deleteProfileImage() {
        selectedImage = nil
    }

    // MARK: - 서버 분류 요청
    func classifyDog() {
        guard let image = selectedImage,
              let url = URL(string: "http://3.35.154.249:8080/classify-dog"),
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"dog.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        DispatchQueue.main.async { self.isLoading = true }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            defer { DispatchQueue.main.async { self.isLoading = false } }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let breed = json["breed"] as? String else { return }

            if let mapped = self.breedMapping[breed] {
                DispatchQueue.main.async {
                    self.breedCode = mapped.code
                    self.breedResult = mapped.korean
                }
            } else {
                DispatchQueue.main.async {
                    self.breedCode = ""
                    self.breedResult = "알 수 없음"
                }
            }
        }.resume()
    }
}
