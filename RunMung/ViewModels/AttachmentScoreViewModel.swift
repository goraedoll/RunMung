//
//  AttachmentScoreViewModel.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation
import SwiftUI

@MainActor
class AttachmentScoreViewModel: ObservableObject {
    // 사용자 입력값
    @Published var breed = "푸들"
    @Published var gender = "M"
    @Published var foodCount = 2
    @Published var environment = "실내"
    @Published var defecation = "정상"
    @Published var foodAmount = 2
    @Published var disease = "정상"
    @Published var size = "소형"
    @Published var weightState = "정상"
    @Published var ageRange = "성년"
    @Published var isNeutered = false
    @Published var age = 2
    
    // 결과 상태
    @Published var isLoading = false
    @Published var predictionResult: PredictionResponse? = nil
    @Published var errorMessage: String? = nil

    // 맵핑 딕셔너리
    let breedMap = ["푸들":"POO","포메라니안":"POM","말라뮤트":"MAL","비숑프리제":"BIC","치와와":"CHL","래브라도리트리버":"LAB","진도":"JIN"]
    let environmentMap = ["실내":"in","실외":"out"]
    let defecationMap = ["정상":"normal","이상":"strange"]
    let diseaseMap = ["정상":"none","이상":"strange"]
    let sizeMap = ["소형":"small","중형":"medium","대형":"big"]
    let weightMap = ["저체중":"low","정상":"normal","과체중":"over"]
    let ageRangeMap = ["유년":"puppy","성년":"adult","노년":"senior"]

    // 서버 요청
    func predictExercise() {
        isLoading = true
        predictionResult = nil
        errorMessage = nil

        let payload: [String: Any] = [
            "breed": breedMap[breed] ?? "POO",
            "class": isNeutered ? "Y" : "N",
            "gender": gender,
            "foodcount": foodCount,
            "environment": environmentMap[environment] ?? "in",
            "defecation": defecationMap[defecation] ?? "normal",
            "foodamount": foodAmount,
            "disease": diseaseMap[disease] ?? "none",
            "size": sizeMap[size] ?? "medium",
            "weightstate": weightMap[weightState] ?? "normal",
            "agerange": ageRangeMap[ageRange] ?? "adult"
        ]

        guard let url = URL(string: "http://3.35.154.249:8000/predict"),
              let body = try? JSONSerialization.data(withJSONObject: payload) else {
            self.errorMessage = "잘못된 요청 데이터"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "데이터 없음"
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(PredictionResponse.self, from: data)
                    withAnimation {
                        self.predictionResult = decoded
                    }
                } catch {
                    self.errorMessage = "응답 파싱 실패"
                }
            }
        }.resume()
    }

    func previewJSON() -> String {
        let payload: [String: Any] = [
            "breed": breedMap[breed] ?? "POO",
            "class": isNeutered ? "Y" : "N",
            "gender": gender,
            "foodcount": foodCount,
            "environment": environmentMap[environment] ?? "in",
            "defecation": defecationMap[defecation] ?? "normal",
            "foodamount": foodAmount,
            "disease": diseaseMap[disease] ?? "none",
            "size": sizeMap[size] ?? "medium",
            "weightstate": weightMap[weightState] ?? "normal",
            "agerange": ageRangeMap[ageRange] ?? "adult"
        ]

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
}
