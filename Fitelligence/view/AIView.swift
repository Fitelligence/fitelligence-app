import SwiftUI

struct AIView: View {
    @State private var viewModel = AIViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title
                Text("AI Assistant")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
                // Feature Boxes
                HStack(spacing: 16) {
                    featureBox(icon: "calendar", color: .blue)
                    featureBox(icon: "sun.max.fill", color: .purple)
                    featureBox(icon: "dumbbell.fill", color: .orange)
                }
                .padding(.horizontal)
                
                // Response Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Error Message
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // AI Response
                        if !viewModel.aiResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Response:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(viewModel.aiResponse)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        } else if !viewModel.isLoading {
                            // Empty State
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Ask me anything about fitness!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        
                        // Loading Indicator
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Thinking...")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Input Area
                VStack(spacing: 12) {
                    // Text Input
                    TextField("Ask me anything...", text: $viewModel.userPrompt, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .lineLimit(1...4)
                        .disabled(viewModel.isLoading)
                        .onSubmit {
                            Task {
                                await viewModel.sendPrompt()
                            }
                        }
                    
                    // Send Button
                    Button(action: {
                        Task {
                            await viewModel.sendPrompt()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Ask AI")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userPrompt.isEmpty || viewModel.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.userPrompt.isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Feature Box Component
    func featureBox(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
                .frame(height: 80)
            
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AIView()
}
