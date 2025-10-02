//
//  CompositionRoot.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

/// Composition root handles dependency wiring following Clean Architecture
final class CompositionRoot {
    
    // MARK: - Data Layer
    private let postRepository: PostRepository
    
    // MARK: - Domain Layer
    private let getFeedUseCase: GetFeedUseCaseProtocol
    private let refreshFeedUseCase: RefreshFeedUseCaseProtocol
    
    init() {
        // Wire up dependencies from outer to inner layers
        self.postRepository = MockPostRepository()
        self.getFeedUseCase = GetFeedUseCase(postRepository: postRepository)
        self.refreshFeedUseCase = RefreshFeedUseCase(postRepository: postRepository)
    }
    
    // MARK: - Factory Methods
    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )
    }
}