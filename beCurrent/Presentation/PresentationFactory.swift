//
//  PresentationFactory.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/3/25.
//

import Foundation

/// Factory for creating Presentation layer dependencies (ViewModels)
@MainActor
final class PresentationFactory {
    private let domainFactory: DomainFactory

    init(domainFactory: DomainFactory) {
        self.domainFactory = domainFactory
    }

    // MARK: - ViewModels

    var feedViewModel: FeedViewModel {
        FeedViewModel(
            getFeedUseCase: domainFactory.getFeedUseCase,
            refreshFeedUseCase: domainFactory.refreshFeedUseCase
        )
    }

    var postCreationViewModel: PostCreationViewModel {
        PostCreationViewModel(createPostUseCase: domainFactory.createPostUseCase)
    }
}
