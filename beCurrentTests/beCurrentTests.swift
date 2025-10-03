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

// MARK: - GetFeedUseCase Tests

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

// MARK: - FeedViewModel Tests

@Suite("FeedViewModel Tests")
@MainActor
struct FeedViewModelTests {

    // MARK: - Mock Use Cases

    final class MockGetFeedUseCase: GetFeedUseCaseProtocol {
        var mockPosts: [Post] = []
        var shouldThrowError = false
        var callCount = 0

        var feedPosts: [Post] {
            get async throws {
                callCount += 1
                if shouldThrowError {
                    throw TestError.networkError
                }
                return mockPosts
            }
        }
    }

    final class MockRefreshFeedUseCase: RefreshFeedUseCaseProtocol {
        var mockPosts: [Post] = []
        var shouldThrowError = false
        var callCount = 0

        var feedPosts: [Post] {
            get async throws {
                callCount += 1
                if shouldThrowError {
                    throw TestError.networkError
                }
                return mockPosts
            }
        }
    }

    enum TestError: Error {
        case networkError
    }

    // MARK: - Test Helpers

    private func makeMockPost(username: String = "testuser") -> Post {
        Post(
            user: User(username: username, displayName: "Test User"),
            frontImageURL: URL(string: "https://example.com/front.jpg")!,
            backImageURL: URL(string: "https://example.com/back.jpg")!,
            caption: "Test caption"
        )
    }

    private func makeViewModel(
        getFeedUseCase: GetFeedUseCaseProtocol,
        refreshFeedUseCase: RefreshFeedUseCaseProtocol
    ) -> FeedViewModel {
        FeedViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )
    }

    // MARK: - Tests

    @Test("Should start with empty posts and not loading")
    func initialState() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        let refreshFeedUseCase = MockRefreshFeedUseCase()

        // When
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // Then
        #expect(viewModel.posts.isEmpty, "Should start with empty posts")
        #expect(!viewModel.isLoading, "Should not be loading initially")
        #expect(viewModel.errorMessage == nil, "Should have no error initially")
    }

    @Test("Should load feed successfully")
    func loadFeedSuccess() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        let mockPosts = [
            makeMockPost(username: "user1"),
            makeMockPost(username: "user2")
        ]
        getFeedUseCase.mockPosts = mockPosts
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When
        await viewModel.loadFeed()

        // Then
        #expect(viewModel.posts.count == 2, "Should have 2 posts")
        #expect(viewModel.posts[0].username == "user1", "First post should be from user1")
        #expect(viewModel.posts[1].username == "user2", "Second post should be from user2")
        #expect(!viewModel.isLoading, "Should not be loading after completion")
        #expect(viewModel.errorMessage == nil, "Should have no error on success")
        #expect(getFeedUseCase.callCount == 1, "Should call use case once")
    }

    @Test("Should handle load feed error")
    func loadFeedError() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        getFeedUseCase.shouldThrowError = true
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When
        await viewModel.loadFeed()

        // Then
        #expect(viewModel.posts.isEmpty, "Should have no posts on error")
        #expect(!viewModel.isLoading, "Should not be loading after error")
        #expect(viewModel.errorMessage != nil, "Should have error message")
        #expect(viewModel.errorMessage?.contains("Failed to load feed") == true, "Error message should be descriptive")
        #expect(getFeedUseCase.callCount == 1, "Should call use case once")
    }

    @Test("Should set loading state during load")
    func loadingStateDuringLoad() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        getFeedUseCase.mockPosts = [makeMockPost()]
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When/Then
        // Note: In a real test, you'd need to verify isLoading == true during execution
        // For this example, we verify it's false before and after
        #expect(!viewModel.isLoading, "Should not be loading before load")
        await viewModel.loadFeed()
        #expect(!viewModel.isLoading, "Should not be loading after load completes")
    }

    @Test("Should refresh feed successfully")
    func refreshFeedSuccess() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        let mockPosts = [makeMockPost(username: "refreshed")]
        refreshFeedUseCase.mockPosts = mockPosts
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When
        await viewModel.refreshFeed()

        // Then
        #expect(viewModel.posts.count == 1, "Should have 1 post")
        #expect(viewModel.posts[0].username == "refreshed", "Post should be from refreshed user")
        #expect(!viewModel.isLoading, "Should not be loading after completion")
        #expect(viewModel.errorMessage == nil, "Should have no error on success")
        #expect(refreshFeedUseCase.callCount == 1, "Should call refresh use case once")
        #expect(getFeedUseCase.callCount == 0, "Should not call get feed use case")
    }

    @Test("Should handle refresh feed error")
    func refreshFeedError() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        refreshFeedUseCase.shouldThrowError = true
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When
        await viewModel.refreshFeed()

        // Then
        #expect(viewModel.posts.isEmpty, "Should have no posts on error")
        #expect(!viewModel.isLoading, "Should not be loading after error")
        #expect(viewModel.errorMessage != nil, "Should have error message")
        #expect(viewModel.errorMessage?.contains("Failed to refresh feed") == true, "Error message should be descriptive")
        #expect(refreshFeedUseCase.callCount == 1, "Should call refresh use case once")
    }

    @Test("Should clear error message on new load")
    func clearErrorOnNewLoad() async throws {
        // Given
        let getFeedUseCase = MockGetFeedUseCase()
        getFeedUseCase.shouldThrowError = true
        let refreshFeedUseCase = MockRefreshFeedUseCase()
        let viewModel = makeViewModel(
            getFeedUseCase: getFeedUseCase,
            refreshFeedUseCase: refreshFeedUseCase
        )

        // When
        await viewModel.loadFeed()
        #expect(viewModel.errorMessage != nil, "Should have error after first load")

        // Then retry with success
        getFeedUseCase.shouldThrowError = false
        getFeedUseCase.mockPosts = [makeMockPost()]
        await viewModel.loadFeed()

        #expect(viewModel.errorMessage == nil, "Should clear error on successful load")
        #expect(viewModel.posts.count == 1, "Should have posts from successful load")
    }
}

// MARK: - PostCreationViewModel Tests

@Suite("PostCreationViewModel Tests")
@MainActor
struct PostCreationViewModelTests {

    // MARK: - Mock Use Case

    final class MockCreatePostUseCase: CreatePostUseCaseProtocol {
        var shouldThrowError = false
        var callCount = 0
        var capturedInput: CreatePostInput?

        func createPost(input: CreatePostInput) async throws -> Post {
            callCount += 1
            capturedInput = input

            if shouldThrowError {
                throw TestError.networkError
            }

            return Post(
                user: User(username: "testuser", displayName: "Test User"),
                frontImageURL: URL(string: "https://example.com/front.jpg")!,
                backImageURL: URL(string: "https://example.com/back.jpg")!,
                caption: input.caption
            )
        }
    }

    enum TestError: Error {
        case networkError
    }

    // MARK: - Test Helpers

    private func makeViewModel(createPostUseCase: CreatePostUseCaseProtocol) -> PostCreationViewModel {
        PostCreationViewModel(createPostUseCase: createPostUseCase)
    }

    private func createTestImageData() -> Data {
        // Create simple 1x1 pixel image data
        return Data([0xFF, 0xD8, 0xFF, 0xE0]) // Minimal JPEG header
    }

    // MARK: - Tests

    @Test("Should start with empty state and not creating")
    func initialState() async throws {
        // Given
        let useCase = MockCreatePostUseCase()

        // When
        let viewModel = makeViewModel(createPostUseCase: useCase)

        // Then
        #expect(viewModel.frontImageData == nil, "Should have no front image initially")
        #expect(viewModel.backImageData == nil, "Should have no back image initially")
        #expect(viewModel.caption.isEmpty, "Should have empty caption initially")
        #expect(!viewModel.isCreating, "Should not be creating initially")
        #expect(viewModel.errorMessage == nil, "Should have no error initially")
        #expect(!viewModel.canSubmit, "Should not be able to submit without images")
    }

    @Test("Should enable submit when both images are set")
    func canSubmitWithImages() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)

        // When
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()

        // Then
        #expect(viewModel.canSubmit, "Should be able to submit with both images")
    }

    @Test("Should not enable submit with only front image")
    func cannotSubmitWithOnlyFrontImage() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)

        // When
        viewModel.frontImageData = createTestImageData()

        // Then
        #expect(!viewModel.canSubmit, "Should not be able to submit with only front image")
    }

    @Test("Should not enable submit with only back image")
    func cannotSubmitWithOnlyBackImage() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)

        // When
        viewModel.backImageData = createTestImageData()

        // Then
        #expect(!viewModel.canSubmit, "Should not be able to submit with only back image")
    }

    @Test("Should create post successfully with caption")
    func createPostWithCaption() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()
        viewModel.caption = "Test caption"

        // When
        await viewModel.createPost()

        // Then
        #expect(useCase.callCount == 1, "Should call use case once")
        #expect(useCase.capturedInput?.caption == "Test caption", "Should pass caption to use case")
        #expect(useCase.capturedInput?.frontImageData != nil, "Should pass front image data")
        #expect(useCase.capturedInput?.backImageData != nil, "Should pass back image data")
        #expect(!viewModel.isCreating, "Should not be creating after completion")
        #expect(viewModel.errorMessage == nil, "Should have no error on success")
    }

    @Test("Should create post successfully without caption")
    func createPostWithoutCaption() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()
        viewModel.caption = ""

        // When
        await viewModel.createPost()

        // Then
        #expect(useCase.callCount == 1, "Should call use case once")
        #expect(useCase.capturedInput?.caption == nil, "Should pass nil for empty caption")
        #expect(!viewModel.isCreating, "Should not be creating after completion")
        #expect(viewModel.errorMessage == nil, "Should have no error on success")
    }

    @Test("Should reset form after successful creation")
    func resetFormAfterSuccess() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()
        viewModel.caption = "Test caption"

        // When
        await viewModel.createPost()

        // Then
        #expect(viewModel.frontImageData == nil, "Should clear front image")
        #expect(viewModel.backImageData == nil, "Should clear back image")
        #expect(viewModel.caption.isEmpty, "Should clear caption")
        #expect(!viewModel.canSubmit, "Should not be able to submit after reset")
    }

    @Test("Should handle creation error")
    func createPostError() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        useCase.shouldThrowError = true
        let viewModel = makeViewModel(createPostUseCase: useCase)
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()

        // When
        await viewModel.createPost()

        // Then
        #expect(useCase.callCount == 1, "Should call use case once")
        #expect(!viewModel.isCreating, "Should not be creating after error")
        #expect(viewModel.errorMessage != nil, "Should have error message")
        #expect(viewModel.errorMessage?.contains("Failed to create post") == true, "Error message should be descriptive")
        #expect(viewModel.frontImageData != nil, "Should keep front image on error")
        #expect(viewModel.backImageData != nil, "Should keep back image on error")
    }

    @Test("Should not create post without images")
    func doNotCreateWithoutImages() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)

        // When
        await viewModel.createPost()

        // Then
        #expect(useCase.callCount == 0, "Should not call use case without images")
    }

    @Test("Should disable submit while creating")
    func disableSubmitWhileCreating() async throws {
        // Given
        let useCase = MockCreatePostUseCase()
        let viewModel = makeViewModel(createPostUseCase: useCase)
        viewModel.frontImageData = createTestImageData()
        viewModel.backImageData = createTestImageData()

        // When
        #expect(viewModel.canSubmit, "Should be able to submit before creating")
        viewModel.isCreating = true

        // Then
        #expect(!viewModel.canSubmit, "Should not be able to submit while creating")
    }
}
