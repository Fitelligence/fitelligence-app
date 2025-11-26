import Foundation
import Observation

@Observable
@MainActor
class AIViewModel {
    // MARK: - Published Properties
    var userPrompt: String = ""
    var aiResponse: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // MARK: - Configuration
    private let endpoint = URL(string: "https://parseapi.back4app.com/functions/aiFunction")!
    private let appId = "1g9mCtQTndUdapOL2URSjzBarbEVJpBxXI09peRa"
    private let restKey = "YOUR_REST_API_KEY"  // Replace with your REST API Key
    
    // MARK: - Send Prompt to Back4App
    func sendPrompt() async {
        // Validate input
        let prompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            errorMessage = "Please enter a prompt"
            return
        }
        
        // Reset state
        isLoading = true
        errorMessage = nil
        aiResponse = ""
        
        // Create request
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        // Add headers
        request.setValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body
        let body: [String: String] = ["prompt": prompt]
        
        do {
            // Encode body to JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Make the request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Server error: \(httpResponse.statusCode)"
                isLoading = false
                return
            }
            
            // Parse response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let result = json["result"] as? String {
                    aiResponse = result
                } else if let result = json["response"] as? String {
                    aiResponse = result
                } else {
                    errorMessage = "Unexpected response format"
                }
            } else {
                errorMessage = "Failed to parse response"
            }
            
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Clear Response
    func clearResponse() {
        aiResponse = ""
        errorMessage = nil
    }
}
