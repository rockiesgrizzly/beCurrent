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
    var frontImage: UIImage?
    var backImage: UIImage?
    var caption: String = ""
    var isCreating: Bool = false
    var errorMessage: String?
    
    // Computed properties
    var canSubmit: Bool {
        frontImage != nil && backImage != nil && !isCreating
    }
    
    init(createPostUseCase: CreatePostUseCaseProtocol) {
        self.createPostUseCase = createPostUseCase
    }
    
    func createPost() async {
        guard let frontImage, let backImage else { return }
        
        isCreating = true
        errorMessage = nil
        
        do {
            guard let frontImageData = frontImage.jpegData(compressionQuality: 0.8),
                  let backImageData = backImage.jpegData(compressionQuality: 0.8) else {
                throw PostCreationError.imageProcessingFailed
            }
            
            _ = try await createPostUseCase.createPost(
                frontImageData: frontImageData,
                backImageData: backImageData,
                caption: caption.isEmpty ? nil : caption
            )
            
            // Reset form after successful creation
            resetForm()
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
        }
        
        isCreating = false
    }
    
    private func resetForm() {
        frontImage = nil
        backImage = nil
        caption = ""
    }
}

enum PostCreationError: LocalizedError {
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process images"
        }
    }
}