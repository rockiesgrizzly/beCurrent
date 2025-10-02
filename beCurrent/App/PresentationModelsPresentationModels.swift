//
//  PresentationModels.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

/// Presentation model for displaying posts in the UI
/// Contains UI-specific formatting and display logic
struct PostPresentationModel: Identifiable {
    let id: String
    let username: String
    let displayName: String
    let frontImageURL: URL
    let backImageURL: URL
    let caption: String?
    let timeAgo: String
    let isLate: Bool
    let lateIndicator: String?
    let profileImageURL: URL?
    
    /// Convert domain Post to presentation model
    init(from post: Post) {
        self.id = post.id.uuidString
        self.username = post.user.username
        self.displayName = post.user.displayName
        self.frontImageURL = post.frontImageURL
        self.backImageURL = post.backImageURL
        self.caption = post.caption
        self.timeAgo = Self.formatTimeAgo(from: post.timestamp)
        self.isLate = post.isLate
        self.lateIndicator = post.isLate ? Self.formatLateIndicator(minutes: post.lateByMinutes) : nil
        self.profileImageURL = post.user.profileImageURL
    }
    
    private static func formatTimeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private static func formatLateIndicator(minutes: Int?) -> String {
        guard let minutes = minutes else { return "Late" }
        return "\(minutes)m late"
    }
}