//
//  DependencyContainer.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

@Observable
final class DependencyContainer {
    
    // MARK: - Composition Root
    private let compositionRoot: CompositionRoot
    
    // MARK: - Initializer
    init(compositionRoot: CompositionRoot = CompositionRoot()) {
        self.compositionRoot = compositionRoot
    }
    
    // MARK: - ViewModels
    func makeFeedViewModel() -> FeedViewModel {
        compositionRoot.makeFeedViewModel()
    }
}
