//
//  DependencyContainer.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

/// App-level dependency container that composes layer-specific factories
/// following Clean Architecture dependency flow: App -> Presentation -> Domain -> Data
@MainActor
@Observable
final class DependencyContainer {

    // MARK: - Layer Factories

    private let dataFactory: DataFactory
    private let domainFactory: DomainFactory
    private let presentationFactory: PresentationFactory

    init() {
        // Initialize factories from outer to inner layers
        self.dataFactory = DataFactory()
        self.domainFactory = DomainFactory(dataFactory: dataFactory)
        self.presentationFactory = PresentationFactory(domainFactory: domainFactory)
    }

    // MARK: - ViewModels

    var feedViewModel: FeedViewModel {
        presentationFactory.feedViewModel
    }

    var postCreationViewModel: PostCreationViewModel {
        presentationFactory.postCreationViewModel
    }
}
