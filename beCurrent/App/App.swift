//
//  App.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/1/25.
//

import SwiftUI

@main
struct beCurrentApp: App {
    @State private var dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(viewModel: dependencyContainer.feedViewModel)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Feed")
                    }
            }
            .environment(dependencyContainer)
        }
    }
}
