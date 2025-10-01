//
//  Item.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/1/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
