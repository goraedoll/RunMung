//
//  DogGuideViewModel.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation

@MainActor
class DogGuideViewModel: ObservableObject {
    @Published var guide: DogGuideResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadGuide(breed: String, workoutLevel: String) async {
        isLoading = true
        errorMessage = nil
        guide = nil

        let request = DogGuideRequest(breeds: breed, workoutLevel: workoutLevel)

        do {
            let response = try await DogGuideManager.shared.fetchDogGuide(request: request)
            self.guide = response
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
