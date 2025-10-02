//
//  PostCreationView.swift
//  beCurrent
//
//  Created by Josh MacDonald on 10/2/25.
//

import SwiftUI

struct PostCreationView: View {
    let viewModel: PostCreationViewModel
    
    // Internal state
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Time to BeCurrent.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("2 minutes left to capture a BeCurrent and see what your friends are up to!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Image preview section
                    VStack(spacing: 16) {
                        if let frontImage = viewModel.frontImage,
                           let backImage = viewModel.backImage {
                            // Show both images in BeCurrent style
                            ZStack(alignment: .topLeading) {
                                // Back camera image
                                Image(uiImage: backImage)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(height: 400)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                // Front camera image (overlay)
                                Image(uiImage: frontImage)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(width: 80, height: 106)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                                    .padding(.leading, 16)
                                    .padding(.top, 16)
                            }
                        } else {
                            // Placeholder for images
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 400)
                                .cornerRadius(12)
                                .overlay {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.gray)
                                        Text("Tap to capture")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onTapGesture {
                                    isShowingCamera = true
                                }
                        }
                        
                        // Capture button
                        if viewModel.frontImage == nil || viewModel.backImage == nil {
                            Button("📸 Capture BeCurrent") {
                                isShowingCamera = true
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Caption field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption...")
                            .font(.headline)
                        
                        TextField("What's happening?", text: Binding(
                            get: { viewModel.caption },
                            set: { viewModel.caption = $0 }
                        ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                    }
                    
                    // Submit button
                    Button("Share BeCurrent") {
                        Task {
                            await viewModel.createPost()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canSubmit ? Color.black : Color.gray)
                    .cornerRadius(12)
                    .disabled(!viewModel.canSubmit)
                    
                    if viewModel.isCreating {
                        ProgressView("Sharing your BeCurrent...")
                            .padding()
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Create BeCurrent")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isShowingCamera) {
            // Camera view would go here
            Text("Camera View\n(Not implemented in walking skeleton)")
                .multilineTextAlignment(.center)
                .padding()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            // Image picker would go here
            Text("Image Picker\n(Not implemented in walking skeleton)")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    let container = DependencyContainer()
    return PostCreationView(viewModel: container.makePostCreationViewModel())
}
