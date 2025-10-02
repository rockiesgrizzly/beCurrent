//
//  PostCardView.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import SwiftUI
import CoreLocation

struct PostCardView: View {
    let post: PostViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with user info and timestamp
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text(post.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if post.isLate, let lateIndicator = post.lateIndicator {
                            Text("• \(lateIndicator)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Dual image layout (BeCurrent style)
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
}

#Preview {
    let mockUser = User(
        username: "preview_user",
        displayName: "Preview User"
    )
    
    let mockPost = Post(
        user: mockUser,
        frontImageURL: URL(string: "https://picsum.photos/400/600")!,
        backImageURL: URL(string: "https://picsum.photos/600/400")!,
        caption: "This is a preview post!",
        timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
        isLate: true,
        lateByMinutes: 15
    )
    
    let postViewModel = PostViewModel(from: mockPost)
    
    PostCardView(post: postViewModel)
        .padding()
}

