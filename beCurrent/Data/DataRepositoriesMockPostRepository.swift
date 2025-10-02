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
    
    private var mockPosts: [Post] {
        let mockUsers = [
            User(username: "alice_doe", displayName: "Alice Doe"),
            User(username: "bob_smith", displayName: "Bob Smith"),
            User(username: "charlie_wilson", displayName: "Charlie Wilson"),
            User(username: "diana_prince", displayName: "Diana Prince")
        ]
        
        // Using placeholder URLs for now - in real app these would be actual image URLs
        let frontImageURL = URL(string: "https://picsum.photos/400/600")!
        let backImageURL = URL(string: "https://picsum.photos/600/400")!
        
        return [
            Post(
                user: mockUsers[0],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: "Coffee and code ☕️",
                location: CLLocation(latitude: 37.7749, longitude: -122.4194),
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isLate: false
            ),
            Post(
                user: mockUsers[1],
                frontImageURL: frontImageURL,
                backImageURL: backImageURL,
                caption: "Late night debugging 🐛",
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
                caption: "Lunch break! 🌮",
                location: CLLocation(latitude: 51.5074, longitude: -0.1278),
                timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
                isLate: true,
                lateByMinutes: 5
            )
        ]
    }
}