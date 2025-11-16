import Foundation
import Combine

@MainActor
class AIViewModel: ObservableObject {
    // UI bindings the view expects
    @Published var userPrompt: String = ""
    @Published var aiResponse: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ---- Replace these with your actual Back4App values ----
    private let endpoint = URL(string: "https://parseapi.back4app.com/functions/aiFunction")! // update if different
    private let appId = "YOUR_APP_ID"
    private let restKey = "YOUR_REST_API_KEY"
    // ---------------------------------------------------------

    // Send prompt to Back4App
    func sendPrompt() {
        // basic validation
        let prompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            self.errorMessage = "Prompt cannot be empty."
            return
        }

        isLoading = true
        aiResponse = ""
        errorMessage = nil

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["prompt": prompt]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            isLoading = false
            errorMessage = "Failed to serialize request body."
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // always go back to main actor for UI updates
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from server."
                    return
                }

                // Try to parse a few possible server response shapes
                // 1) {"result": "some text"}
                // 2) {"response": "some text"}
                // 3) plain string returned (unlikely) or nested data
                do {
                    if
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let result = (json["result"] as? String) ?? (json["response"] as? String)
                    {
                        self.aiResponse = result
                        return
                    }

                    // Try top-level string (some endpoints return {"result": {"text": "..."}}, adapt if needed)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let nested = json["result"] as? [String: Any],
                       let text = nested["text"] as? String
                    {
                        self.aiResponse = text
                        return
                    }

                    // As a fallback, try decoding the raw data as a string
                    if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                        // Removing possible JSON wrapping for display is left to your backend shape
                        self.aiResponse = raw
                        return
                    }

                    self.errorMessage = "Unexpected response format."
                } catch {
                    self.errorMessage = "JSON parse error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
