//
//  MockPostRepository.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation
import CoreLocation

final class MockPostRepository: PostRepository {
    
    var feed: [Post] {
        get async throws {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            return mockPosts
        }
    }
    
    var refreshedFeed: [Post] {
        get async throws {
            // Simulate refresh with slightly longer delay
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // In a real app, this might return updated posts
            return mockPosts
        }
    }
    
    func createPost(post: Post) async throws -> Post {
        // Simulate network delay for post creation
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // In a real app, this would upload to server and return the created post
        return post
    }
    
    private var mockPosts: [Post] {
        let mockUsers = [
            User(username: "vessel", displayName: "Vessel"),
            User(username: "ii", displayName: "II"),
            User(username: "iii", displayName: "III"),
            User(username: "iv", displayName: "IV")
        ]
        
        // Using placeholder URLs for now - in real app these would be actual image URLs
        let frontImageURL = URL(string: "https://picsum.photos/400/600")!
        let backImageURL = URL(string: "https://picsum.photos/600/400")!
        
        return [
            Post(
                user: mockUsers[0],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: "Morning ritual ☕️",
                location: CLLocation(latitude: 37.7749, longitude: -122.4194),
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isLate: false
            ),
            Post(
                user: mockUsers[1],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: "Late night sessions 🌙",
                location: CLLocation(latitude: 40.7128, longitude: -74.0060),
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                isLate: true,
                lateByMinutes: 23
            ),
            Post(
                user: mockUsers[2],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: nil,
                location: CLLocation(latitude: 34.0522, longitude: -118.2437),
                timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                isLate: false
            ),
            Post(
                user: mockUsers[3],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: "Take me back to Eden 🌿",
                location: CLLocation(latitude: 51.5074, longitude: -0.1278),
                timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
                isLate: true,
                lateByMinutes: 5
            )
        ]
    }
}