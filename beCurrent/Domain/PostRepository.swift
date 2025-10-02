//
//  PostRepository.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

protocol PostRepository {
    var feed: [Post] { get async throws }
    func createPost(post: Post) async throws -> Post
    var refreshedFeed: [Post] { get async throws }
}

protocol UserRepository {
    var currentUser: User { get async throws }
}
