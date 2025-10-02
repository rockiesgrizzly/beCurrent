//
//  BeRealPost.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import Foundation
import CoreLocation

struct BeRealPost: Identifiable, Equatable {
    let id: UUID
    let user: User
    let frontImageURL: URL
    let backImageURL: URL
    let caption: String?
    let location: CLLocation?
    let timestamp: Date
    let isLate: Bool
    let lateByMinutes: Int?
    
    init(
        id: UUID = UUID(),
        user: User,
        frontImageURL: URL,
        backImageURL: URL,
        caption: String? = nil,
        location: CLLocation? = nil,
        timestamp: Date = Date(),
        isLate: Bool = false,
        lateByMinutes: Int? = nil
    ) {
        self.id = id
        self.user = user
        self.frontImageURL = frontImageURL
        self.backImageURL = backImageURL
        self.caption = caption
        self.location = location
        self.timestamp = timestamp
        self.isLate = isLate
        self.lateByMinutes = lateByMinutes
    }
}