import SwiftUI

struct AIView: View {
    @StateObject private var viewModel = AIViewModel()
    @State private var conversationHistory: [Message] = []

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
                    featureBox(
                        icon: "calendar",
                        color: .blue,
                        label: "Schedule",
                        action: { insertQuickPrompt("Help me create a workout schedule") }
                    )
                    featureBox(
                        icon: "sun.max.fill",
                        color: .purple,
                        label: "Nutrition",
                        action: { insertQuickPrompt("Give me nutrition advice") }
                    )
                    featureBox(
                        icon: "dumbbell.fill",
                        color: .orange,
                        label: "Exercise",
                        action: { insertQuickPrompt("Recommend exercises for") }
                    )
                }
                .padding(.horizontal)

                // Conversation History
                if !conversationHistory.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(conversationHistory) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onChange(of: conversationHistory.count) { _, _ in
                            // Auto-scroll to latest message
                            if let lastMessage = conversationHistory.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Start a conversation")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Ask about workouts, nutrition, or fitness advice")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                }

                Spacer()

                // Input Area
                VStack(spacing: 12) {
                    // Error Message (if any)
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                            Button(action: { viewModel.errorMessage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    // Input Field with Send Button
                    HStack(spacing: 12) {
                        TextField("Ask me anything...", text: $viewModel.userPrompt, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .lineLimit(1...4)
                            .disabled(viewModel.isLoading)
                            .onSubmit {
                                sendMessage()
                            }

                        // Send Button
                        Button(action: sendMessage) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.userPrompt.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                    .frame(width: 44, height: 44)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 18, weight: .semibold))
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearConversation) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(conversationHistory.isEmpty)
                }
            }
        }
    }

    // MARK: - Feature Box Component
    func featureBox(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .frame(height: 70)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Helper Functions
    private func sendMessage() {
        let prompt = viewModel.userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        
        // Add user message to history
        let userMessage = Message(content: prompt, isUser: true)
        conversationHistory.append(userMessage)
        
        // Clear input field immediately
        let currentPrompt = viewModel.userPrompt
        viewModel.userPrompt = ""
        
        // Send to AI
        viewModel.userPrompt = currentPrompt
        viewModel.sendPrompt()
        
        // Listen for response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            observeResponse()
        }
    }
    
    private func observeResponse() {
        // Check periodically for response
        if !viewModel.isLoading && !viewModel.aiResponse.isEmpty {
            let aiMessage = Message(content: viewModel.aiResponse, isUser: false)
            conversationHistory.append(aiMessage)
            viewModel.aiResponse = ""
            viewModel.userPrompt = ""
        } else if !viewModel.isLoading {
            // Try again in a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !viewModel.aiResponse.isEmpty {
                    let aiMessage = Message(content: viewModel.aiResponse, isUser: false)
                    conversationHistory.append(aiMessage)
                    viewModel.aiResponse = ""
                    viewModel.userPrompt = ""
                }
            }
        }
    }
    
    private func insertQuickPrompt(_ prompt: String) {
        viewModel.userPrompt = prompt
    }
    
    private func clearConversation() {
        conversationHistory.removeAll()
        viewModel.userPrompt = ""
        viewModel.aiResponse = ""
        viewModel.errorMessage = nil
    }
}

// MARK: - Message Model
struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !message.isUser { Spacer(minLength: 60) }
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    AIView()
}
