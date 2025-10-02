//
//  PostRepository.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

protocol PostRepository {
    var feed: [Post] { get async throws }
}