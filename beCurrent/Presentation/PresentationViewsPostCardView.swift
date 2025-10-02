//
//  PostCardView.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import SwiftUI
import CoreLocation

struct PostCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with user info and timestamp
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text(formatTimeAgo(post.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if post.isLate, let minutes = post.lateByMinutes {
                            Text("• \(minutes)min late")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if post.location != nil {
                            Text("• 📍")
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Dual image layout (BeReal style)
            ZStack(alignment: .topLeading) {
                // Back camera (main image)
                AsyncImage(url: post.backImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(3/4, contentMode: .fill)
                        .overlay {
                            ProgressView()
                        }
                }
                .cornerRadius(12)
                
                // Front camera (small overlay)
                AsyncImage(url: post.frontImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(3/4, contentMode: .fill)
                        .overlay {
                            ProgressView()
                                .scaleEffect(0.5)
                        }
                }
                .frame(width: 80, height: 106)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 4)
                .padding(.leading, 16)
                .padding(.top, 16)
            }
            
            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        
        if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    let mockUser = User(username: "preview_user", displayName: "Preview User")
    let mockPost = Post(
        user: mockUser,
        frontImageURL: URL(string: "https://picsum.photos/400/600")!,
        backImageURL: URL(string: "https://picsum.photos/600/400")!,
        caption: "This is a preview post!",
        timestamp: Date().addingTimeInterval(-3600),
        isLate: true,
        lateByMinutes: 15
    )
    
    return PostCardView(post: mockPost)
        .padding()
}