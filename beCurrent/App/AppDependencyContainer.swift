//
//  DependencyContainer.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

@Observable
final class DependencyContainer {
    
    // MARK: - Data Layer Dependencies
    private let postRepository: PostRepository
    private let userRepository: UserRepository
    
    // MARK: - Domain Layer Dependencies  
    private let getFeedUseCase: GetFeedUseCaseProtocol
    private let refreshFeedUseCase: RefreshFeedUseCaseProtocol
    private let createPostUseCase: CreatePostUseCaseProtocol
    
    init() {
        // Initialize repositories first
        self.postRepository = MockPostRepository()
        self.userRepository = MockUserRepository()
        
        // Then initialize use cases with repository dependencies
        self.getFeedUseCase = GetFeedUseCase(postRepository: postRepository)
        self.refreshFeedUseCase = RefreshFeedUseCase(postRepository: postRepository)
        self.createPostUseCase = CreatePostUseCase(postRepository: postRepository, userRepository: userRepository)
    }
    
    // MARK: - ViewModels
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )
    }
    
    func makePostCreationViewModel() -> PostCreationViewModel {
        PostCreationViewModel(createPostUseCase: createPostUseCase)
    }
}
