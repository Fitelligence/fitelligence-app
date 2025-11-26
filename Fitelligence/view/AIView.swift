import SwiftUI

struct AIView: View {
    @State private var viewModel = AIViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title
                Text("AI Assistant")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
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
                    // Text Input with Send Button
                    HStack(spacing: 12) {
                        TextField("Ask me anything...", text: $viewModel.userPrompt, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .lineLimit(1...4)
                            .disabled(viewModel.isLoading)
                            .focused($isTextFieldFocused)
                            .submitLabel(.send)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        // Send Button (Circle with Arrow)
                        Button(action: {
                            sendMessage()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.userPrompt.isEmpty || viewModel.isLoading ? Color.gray.opacity(0.3) : Color.blue)
                                    .frame(width: 44, height: 44)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(viewModel.userPrompt.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }
    
    // MARK: - Send Message Function
    private func sendMessage() {
        guard !viewModel.userPrompt.isEmpty && !viewModel.isLoading else { return }
        
        isTextFieldFocused = false // Dismiss keyboard
        
        Task {
            await viewModel.sendPrompt()
        }
    }
}

#Preview {
    AIView()
}
