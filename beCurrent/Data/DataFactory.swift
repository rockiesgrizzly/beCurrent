//
//  DataFactory.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/3/25.
//

import Foundation

/// Factory for creating Data layer dependencies
final class DataFactory {

    // MARK: - Repositories

    var postRepository: PostRepository {
        MockPostRepository()
    }

    var userRepository: UserRepository {
        MockUserRepository()
    }
}
