//
//  DogGuideManager.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation

class DogGuideManager {
    static let shared = DogGuideManager()
    private init() {}

    private let baseURL = "http://ec2-3-39-9-151.ap-northeast-2.compute.amazonaws.com:3000/api/dog-guide"

    func fetchDogGuide(request: DogGuideRequest) async throws -> DogGuideResponse {
        guard let url = URL(string: "\(baseURL)/guide") else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        // 🔎 요청 로그
        if let body = urlRequest.httpBody,
           let json = String(data: body, encoding: .utf8) {
            print("➡️ DogGuide Request JSON:", json)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // 🔎 응답 코드 로그
        print("⬅️ DogGuide Response Code:", httpResponse.statusCode)

        if !(200...299).contains(httpResponse.statusCode) {
            let raw = String(data: data, encoding: .utf8) ?? "nil"
            print("❌ DogGuide Error Body:", raw)
            throw URLError(.badServerResponse)
        }

        // 🔎 응답 데이터 로그
        let raw = String(data: data, encoding: .utf8) ?? "nil"
        print("⬅️ DogGuide Raw Response:", raw)

        return try JSONDecoder().decode(DogGuideResponse.self, from: data)
    }
}
