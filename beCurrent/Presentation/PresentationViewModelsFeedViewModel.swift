//
//  FeedViewModel.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

@MainActor
@Observable
final class FeedViewModel {
    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?
    
    private let getFeedUseCase: GetFeedUseCaseProtocol
    
    init(getFeedUseCase: GetFeedUseCaseProtocol) {
        self.getFeedUseCase = getFeedUseCase
    }
    
    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let feedPosts = try await getFeedUseCase.feedPosts
            posts = feedPosts
        } catch {
            errorMessage = "Failed to load feed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshFeed() async {
        await loadFeed()
    }
}