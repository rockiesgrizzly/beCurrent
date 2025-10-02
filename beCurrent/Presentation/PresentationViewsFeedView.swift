//
//  FeedView.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import SwiftUI

struct FeedView: View {
    @State private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading feed...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("😕")
                            .font(.system(size: 64))
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.refreshFeed()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                PostCardView(post: post)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshFeed()
                    }
                }
            }
            .navigationTitle("BeReal")
            .task {
                await viewModel.loadFeed()
            }
        }
    }
}

#Preview {
    let container = DependencyContainer()
    return FeedView(viewModel: container.makeFeedViewModel())
}