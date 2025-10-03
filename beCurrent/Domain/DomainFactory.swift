//
//  DomainFactory.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/3/25.
//

import Foundation

/// Factory for creating Domain layer dependencies (Use Cases)
final class DomainFactory {
    private let dataFactory: DataFactory

    init(dataFactory: DataFactory) {
        self.dataFactory = dataFactory
    }

    // MARK: - Use Cases

    var getFeedUseCase: GetFeedUseCaseProtocol {
        GetFeedUseCase(postRepository: dataFactory.postRepository)
    }

    var refreshFeedUseCase: RefreshFeedUseCaseProtocol {
        RefreshFeedUseCase(postRepository: dataFactory.postRepository)
    }

    var createPostUseCase: CreatePostUseCaseProtocol {
        CreatePostUseCase(
            postRepository: dataFactory.postRepository,
            userRepository: dataFactory.userRepository
        )
    }
}
