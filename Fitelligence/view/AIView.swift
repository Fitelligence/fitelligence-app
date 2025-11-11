
//  AIView.swift
//  Fitelligence
//
//  Created by sam will on 11/10/25.
//


import SwiftUI

struct AIView: View {
    @State private var userPrompt: String = ""
    @State private var aiResponse: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Replace with your actual Back4App info
    private let apiURL = URL(string: "https://parseapi.back4app.com/functions/aiFunction")! // Example endpoint
    private let appId = "YOUR_APP_ID"
    private let restKey = "YOUR_REST_API_KEY"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("AI Assistant")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter your prompt here...", text: $userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendPrompt) {
                    HStack {
                        if isLoading {
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
                .disabled(userPrompt.isEmpty || isLoading)

                ScrollView {
                    if let error = errorMessage {
                        Text("⚠️ \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else if !aiResponse.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("AI Response:")
                                .font(.headline)
                            Text(aiResponse)
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

    // MARK: - Networking Function
    func sendPrompt() {
        guard !userPrompt.isEmpty else { return }
        isLoading = true
        aiResponse = ""
        errorMessage = nil

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["prompt": userPrompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No response data received."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? String {
                    DispatchQueue.main.async {
                        aiResponse = result
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid response format."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    AIView()
}
