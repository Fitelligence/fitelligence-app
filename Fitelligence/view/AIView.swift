import SwiftUI

struct AIView: View {
    @StateObject private var viewModel = AIViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Title
                Text("AI Assistant")
                    .font(.largeTitle)
                    .bold()

                // User Text Input
                TextField("Enter your prompt here...", text: $viewModel.userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // --- NEW THREE BOXES ---
                HStack(spacing: 16) {
                    featureBox(icon: "calendar", color: .blue)
                    featureBox(icon: "sun.max.fill", color: .purple)
                    featureBox(icon: "dumbbell.fill", color: .orange)
                }
                .padding(.horizontal)

                // Ask AI Button
                Button(action: viewModel.sendPrompt) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        Text("Ask AI")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(viewModel.userPrompt.isEmpty || viewModel.isLoading)

                // Display AI Response
                ScrollView {
                    if let error = viewModel.errorMessage {
                        // <-- fixed string interpolation with emoji
                        Text("⚠️ \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else if !viewModel.aiResponse.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("AI Response:")
                                .font(.headline)
                            Text(viewModel.aiResponse)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    } else {
                        Text("Your AI responses will appear here.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("AI Chat")
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
