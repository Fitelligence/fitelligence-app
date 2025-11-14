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
                HStack {
                    TextField("Enter your prompt here...", text: $viewModel.userPrompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 300)
                }
                .frame(maxWidth: .infinity)

                // --- NEW THREE BOXES ---
                HStack(spacing: 16) {

                    // Blue Calendar Box
                    featureBox(icon: "calendar", color: .blue)

                    // Purple Sun Box
                    featureBox(icon: "sun.max.fill", color: .purple)

                    // Orange Weight Box (dumbbell)
                    featureBox(icon: "dumbbell.fill", color: .orange)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                // --- END NEW BOXES ---

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
