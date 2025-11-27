//
//  MainTabView.swift
//  Fitelligence
//
//  Created by Jake Capuana on 11/24/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Calendar/Workout Planner Tab - Using Robert's view
            CustomCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                }
                .tag(0)
            
            // AI Assistant Tab
            AIAssistantView()
                .tabItem {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                }
                .tag(1)
            
            // My Exercises Tab
            MyExercisesView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 24))
                }
                .tag(2)
        }
        .accentColor(.blue) // Selected tab color
    }
}

// AI assistant view
struct AIAssistantView: View {
    @State private var viewModel = AIViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Response Area
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Text("Thinking...")
                        .foregroundColor(.gray)
                }
            } else if !viewModel.aiResponse.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fitelligence says:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.aiResponse)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Ask Fitelligence Anything")
                        .font(.title2)
                        .bold()
                }
            }
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Input field with send button
            HStack(spacing: 12) {
                TextField("Suggest a good workout routine for leg day...", text: $viewModel.userPrompt, axis: .vertical)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(25)
                    .lineLimit(1...4)
                    .focused($isTextFieldFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                    .disabled(viewModel.isLoading)
                
                // Send Button
                Button(action: {
                    sendMessage()
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.userPrompt.isEmpty || viewModel.isLoading ? Color.gray.opacity(0.3) : Color.purple)
                            .frame(width: 50, height: 50)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(viewModel.userPrompt.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private func sendMessage() {
        guard !viewModel.userPrompt.isEmpty && !viewModel.isLoading else { return }
        isTextFieldFocused = false
        Task {
            await viewModel.sendPrompt()
        }
    }
}

#Preview {
    MainTabView()
}
