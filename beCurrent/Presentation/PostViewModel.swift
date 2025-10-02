//
//  PostViewModel.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

/// View model for displaying posts in the UI
/// Contains UI-specific formatting and display logic
struct PostViewModel: Identifiable {
    let id: String
    let username: String
    let frontImageURL: URL
    let backImageURL: URL
    let caption: String?
    let timeAgo: String
    let isLate: Bool
    let lateIndicator: String?
    
    /// Convert domain Post to view model
    init(from post: Post) {
        self.id = post.id.uuidString
        self.username = post.user.username
        self.frontImageURL = post.frontImageURL
        self.backImageURL = post.backImageURL
        self.caption = post.caption
        self.timeAgo = Self.formatTimeAgo(from: post.timestamp)
        self.isLate = post.isLate
        self.lateIndicator = post.isLate ? Self.formatLateIndicator(minutes: post.lateByMinutes) : nil
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