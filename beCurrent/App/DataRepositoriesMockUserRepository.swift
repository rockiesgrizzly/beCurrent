//
//  MockUserRepository.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

final class MockUserRepository: UserRepository {
    private let _currentUser = User(
        id: UUID(),
        username: "you",
        displayName: "You",
        profileImageURL: URL(string: "https://picsum.photos/150/150")
    )
    
    var currentUser: User {
        get async throws {
            // Simulate slight delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            return _currentUser
        }
    }
}
