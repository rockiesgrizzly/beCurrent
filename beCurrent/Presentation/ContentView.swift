//
//  ContentView.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(DependencyContainer.self) private var dependencyContainer
    
    var body: some View {
        TabView {
            FeedView(viewModel: dependencyContainer.makeFeedViewModel())
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(DependencyContainer())
}
