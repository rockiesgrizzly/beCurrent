//
//  GetFeedUseCase.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

protocol GetFeedUseCaseProtocol {
    var feedPosts: [Post] { get async throws }
}

protocol RefreshFeedUseCaseProtocol {
    var feedPosts: [Post] { get async throws }
}

final class GetFeedUseCase: GetFeedUseCaseProtocol {
    private let postRepository: PostRepository
    
    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }
    
    var feedPosts: [Post] {
        get async throws {
            return try await postRepository.feed
        }
    }
}

final class RefreshFeedUseCase: RefreshFeedUseCaseProtocol {
    private let postRepository: PostRepository
    
    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }
    
    var feedPosts: [Post] {
        get async throws {
            return try await postRepository.refreshedFeed
        }
    }
}