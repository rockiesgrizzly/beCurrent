//
//  PostCreationViewModel.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import SwiftUI

@MainActor
@Observable
final class PostCreationViewModel {
    // Dependencies
    private let createPostUseCase: CreatePostUseCaseProtocol

    // Public state properties
    var frontImageData: Data?
    var backImageData: Data?
    var caption: String = ""
    var isCreating: Bool = false
    var errorMessage: String?

    // Computed properties
    var canSubmit: Bool {
        frontImageData != nil && backImageData != nil && !isCreating
    }

    init(createPostUseCase: CreatePostUseCaseProtocol) {
        self.createPostUseCase = createPostUseCase
    }

    func createPost() async {
        guard let frontImageData, let backImageData else { return }

        isCreating = true
        errorMessage = nil

        do {
            let input = CreatePostInput(
                frontImageData: frontImageData,
                backImageData: backImageData,
                caption: caption.isEmpty ? nil : caption
            )

            _ = try await createPostUseCase.createPost(input: input)

            // Reset form after successful creation
            resetForm()
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
        }

        isCreating = false
    }

    private func resetForm() {
        frontImageData = nil
        backImageData = nil
        caption = ""
    }
}