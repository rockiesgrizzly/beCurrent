//
//  User.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation

struct User: Identifiable, Equatable {
    let id: UUID
    let username: String
    let displayName: String
    let profileImageURL: URL?
    
    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        profileImageURL: URL? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profileImageURL = profileImageURL
    }
}