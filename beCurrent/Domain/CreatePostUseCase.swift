//
//  CreatePostUseCase.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

struct CreatePostInput {
    let frontImageData: Data
    let backImageData: Data
    let caption: String?

    init(frontImageData: Data, backImageData: Data, caption: String? = nil) {
        self.frontImageData = frontImageData
        self.backImageData = backImageData
        self.caption = caption
    }
}

protocol CreatePostUseCaseProtocol {
    func createPost(input: CreatePostInput) async throws -> Post
}

final class CreatePostUseCase: CreatePostUseCaseProtocol {
    private let postRepository: PostRepository
    private let userRepository: UserRepository
    
    init(postRepository: PostRepository, userRepository: UserRepository) {
        self.postRepository = postRepository
        self.userRepository = userRepository
    }
    
    func createPost(input: CreatePostInput) async throws -> Post {
        let currentUser = try await userRepository.currentUser

        // In a real app, you'd upload images and get URLs
        // For now, we'll create mock URLs
        let frontImageURL = URL(string: "https://example.com/front/\(UUID().uuidString)")!
        let backImageURL = URL(string: "https://example.com/back/\(UUID().uuidString)")!

        let newPost = Post(
            id: UUID(),
            user: currentUser,
            frontImageURL: frontImageURL,
            backImageURL: backImageURL,
            caption: input.caption,
            location: nil, // Could be added later with location services
            timestamp: Date(),
            isLate: false, // Business logic to determine if late
            lateByMinutes: nil
        )

        return try await postRepository.createPost(post: newPost)
    }
}
