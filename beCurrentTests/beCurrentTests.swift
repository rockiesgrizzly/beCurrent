//
//  beCurrentTests.swift
//  beCurrentTests
//
//  Created by Josh MacDonald on 10/1/25.
//

import Testing
import Foundation
import CoreLocation
@testable import beCurrent

@Suite("GetFeedUseCase Tests")
struct GetFeedUseCaseTests {
    
    // MARK: - Mock Repository
    
    final class MockPostRepositoryForTesting: PostRepository {
        var shouldThrowError = false
        var mockPosts: [Post] = []
        var feedCallCount = 0
        var refreshedFeedCallCount = 0
        var createPostCallCount = 0
        
        var feed: [Post] {
            get async throws {
                feedCallCount += 1
                
                if shouldThrowError {
                    throw TestError.networkError
                }
                
                return mockPosts
            }
        }
        
        var refreshedFeed: [Post] {
            get async throws {
                refreshedFeedCallCount += 1
                
                if shouldThrowError {
                    throw TestError.networkError
                }
                
                return mockPosts
            }
        }
        
        func createPost(post: Post) async throws -> Post {
            createPostCallCount += 1
            
            if shouldThrowError {
                throw TestError.networkError
            }
            
            return post
        }
    }
    
    enum TestError: Error {
        case networkError
    }
    
    // MARK: - Test Helpers
    
    private func makeMockPost(username: String = "testuser") -> Post {
        Post(
            user: User(username: username, displayName: "Test User"),
            frontImageURL: URL(string: "https://sleeptoken.com/front.jpg")!,
            backImageURL: URL(string: "https://sleeptoken.com/back.jpg")!,
            caption: "Test caption"
        )
    }
    
    private func makeUseCase(with repository: MockPostRepositoryForTesting) -> GetFeedUseCase {
        GetFeedUseCase(postRepository: repository)
    }
    
    // MARK: - Tests
    
    @Test("Should return empty array when repository returns no posts")
    func returnsEmptyArrayWhenNoPostsAvailable() async throws {
        // Given
        let mockRepository = MockPostRepositoryForTesting()
        mockRepository.mockPosts = []
        let useCase = makeUseCase(with: mockRepository)
        
        // When
        let result = try await useCase.feedPosts
        
        // Then
        #expect(result.isEmpty, "Should return empty array when no posts available")
        #expect(mockRepository.feedCallCount == 1, "Should call repository once")
    }
    
    @Test("Should return posts when repository has posts")
    func returnsPostsWhenAvailable() async throws {
        // Given
        let mockRepository = MockPostRepositoryForTesting()
        let expectedPosts = [
            makeMockPost(username: "user1"),
            makeMockPost(username: "user2")
        ]
        mockRepository.mockPosts = expectedPosts
        let useCase = makeUseCase(with: mockRepository)
        
        // When
        let result = try await useCase.feedPosts
        
        // Then
        #expect(result.count == 2, "Should return 2 posts")
        #expect(result == expectedPosts, "Should return the same posts from repository")
        #expect(mockRepository.feedCallCount == 1, "Should call repository once")
    }
    
    @Test("Should propagate error when repository throws")
    func propagatesRepositoryError() async throws {
        // Given
        let mockRepository = MockPostRepositoryForTesting()
        mockRepository.shouldThrowError = true
        let useCase = makeUseCase(with: mockRepository)
        
        // When/Then
        await #expect(throws: TestError.networkError) {
            _ = try await useCase.feedPosts
        }
        
        #expect(mockRepository.feedCallCount == 1, "Should call repository once before throwing")
    }
    
    @Test("Should call repository each time feedPosts is accessed")
    func callsRepositoryEachAccess() async throws {
        // Given
        let mockRepository = MockPostRepositoryForTesting()
        mockRepository.mockPosts = [makeMockPost()]
        let useCase = makeUseCase(with: mockRepository)
        
        // When
        _ = try await useCase.feedPosts
        _ = try await useCase.feedPosts
        
        // Then
        #expect(mockRepository.feedCallCount == 2, "Should call repository twice for two accesses")
    }
}
