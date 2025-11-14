import Foundation

@MainActor
class AIViewModel: ObservableObject {
    @Published var userPrompt = ""
    @Published var aiResponse = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiURL = URL(string: "https://parseapi.back4app.com/functions/aiFunction")!
    private let appId = "YOUR_APP_ID"
    private let restKey = "YOUR_REST_API_KEY"

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

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            Task { @MainActor in
                self?.isLoading = false
            }

            if let error = error {
                Task { @MainActor in
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                Task { @MainActor in
                    self?.errorMessage = "No response data received."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? String {
                    Task { @MainActor in
                        self?.aiResponse = result
                    }
                } else {
                    Task { @MainActor in
                        self?.errorMessage = "Invalid response format."
                    }
                }
            } catch {
                Task { @MainActor in
                    self?.errorMessage = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
