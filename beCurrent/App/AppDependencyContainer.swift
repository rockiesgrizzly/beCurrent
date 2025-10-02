//
//  DependencyContainer.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

@Observable
final class DependencyContainer {
    
    // MARK: - Repositories
    private static var postRepository: PostRepository = MockPostRepository()
    
    // MARK: - Use Cases
    private var getFeedUseCase: GetFeedUseCaseProtocol
    
    // MARK: - Initializer
    init() {
        self.getFeedUseCase = GetFeedUseCase(postRepository: Self.postRepository)
    }
    
    // MARK: - ViewModels
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(getFeedUseCase: getFeedUseCase)
    }
}
