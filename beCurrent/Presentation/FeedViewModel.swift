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
    var posts: [PostViewModel] = []
    var isLoading = false
    var errorMessage: String?
    
    private let getFeedUseCase: GetFeedUseCaseProtocol
    private let refreshFeedUseCase: RefreshFeedUseCaseProtocol
    
    init(
        getFeedUseCase: GetFeedUseCaseProtocol,
        refreshFeedUseCase: RefreshFeedUseCaseProtocol
    ) {
        self.getFeedUseCase = getFeedUseCase
        self.refreshFeedUseCase = refreshFeedUseCase
    }
    
    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let domainPosts = try await getFeedUseCase.feedPosts
            posts = domainPosts.map(PostViewModel.init)
        } catch {
            errorMessage = "Failed to load feed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let domainPosts = try await refreshFeedUseCase.feedPosts
            posts = domainPosts.map(PostViewModel.init)
        } catch {
            errorMessage = "Failed to refresh feed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
