import Foundation
import Combine

@MainActor
class AIViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userPrompt: String = ""
    @Published var aiResponse: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var conversationHistory: [(prompt: String, response: String)] = []
    
    // MARK: - Configuration
    private let endpoint = URL(string: "https://parseapi.back4app.com/functions/getWorkoutPlan")!
    private let appId = "1g9mCtQTndUdapOL2URSjzBarbEVJpBxXI09peRa"
    private let restKey = "mtNfXHtOc1fkkWZokBaRNlr2KxBJ3KxvABraR4fc
"  // ← Add your REST API Key here
    
    // Network configuration
    private let timeoutInterval: TimeInterval = 30.0
    private let maxRetries = 2
    private var currentRetry = 0
    
    // Cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Send Prompt
    func sendPrompt() {
        let prompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard !prompt.isEmpty else {
            showError("Prompt cannot be empty.")
            return
        }
        
        guard prompt.count <= 1000 else {
            showError("Prompt is too long. Please keep it under 1000 characters.")
            return
        }
        
        // Reset state
        isLoading = true
        aiResponse = ""
        errorMessage = nil
        currentRetry = 0
        
        // Send request
        performRequest(prompt: prompt)
    }
    
    // MARK: - Perform Request
    private func performRequest(prompt: String) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        
        // Headers
        request.addValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body
        let body: [String: Any] = ["prompt": prompt]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            showError("Failed to prepare request.")
            return
        }
        request.httpBody = httpBody
        
        // Execute request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Handle network error
                if let error = error {
                    self.handleNetworkError(error, prompt: prompt)
                    return
                }
                
                // Handle HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        self.handleHTTPError(statusCode: httpResponse.statusCode, data: data, prompt: prompt)
                        return
                    }
                }
                
                // Handle missing data
                guard let data = data else {
                    self.isLoading = false
                    self.showError("No data received from server.")
                    return
                }
                
                // Parse response
                self.parseResponse(data: data, prompt: prompt)
            }
        }.resume()
    }
    
    // MARK: - Parse Response
    private func parseResponse(data: Data, prompt: String) {
        do {
            // Try parsing as JSON
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Format 1: { "result": "text" }
                if let result = json["result"] as? String {
                    handleSuccess(response: result, prompt: prompt)
                    return
                }
                
                // Format 2: { "response": "text" }
                if let response = json["response"] as? String {
                    handleSuccess(response: response, prompt: prompt)
                    return
                }
                
                // Format 3: { "result": { "text": "..." } }
                if let nested = json["result"] as? [String: Any],
                   let text = nested["text"] as? String {
                    handleSuccess(response: text, prompt: prompt)
                    return
                }
                
                // Format 4: { "error": "message" }
                if let error = json["error"] as? String {
                    isLoading = false
                    showError("Server error: \(error)")
                    return
                }
            }
            
            // Fallback: Try reading as plain text
            if let rawText = String(data: data, encoding: .utf8), !rawText.isEmpty {
                handleSuccess(response: rawText, prompt: prompt)
                return
            }
            
            // If nothing worked
            isLoading = false
            showError("Unexpected response format from server.")
            
        } catch {
            isLoading = false
            showError("Failed to parse response: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Handle Success
    private func handleSuccess(response: String, prompt: String) {
        isLoading = false
        aiResponse = response
        conversationHistory.append((prompt: prompt, response: response))
        userPrompt = "" // Clear input after successful response
        print("✅ AI Response received successfully")
    }
    
    // MARK: - Error Handling
    private func handleNetworkError(_ error: Error, prompt: String) {
        let nsError = error as NSError
        
        // Check if it's a timeout
        if nsError.code == NSURLErrorTimedOut {
            if currentRetry < maxRetries {
                currentRetry += 1
                print("⚠️ Request timed out. Retrying (\(currentRetry)/\(maxRetries))...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.performRequest(prompt: prompt)
                }
                return
            } else {
                isLoading = false
                showError("Request timed out. Please check your connection and try again.")
                return
            }
        }
        
        // Check if no internet connection
        if nsError.code == NSURLErrorNotConnectedToInternet {
            isLoading = false
            showError("No internet connection. Please check your network.")
            return
        }
        
        // Generic network error
        isLoading = false
        showError("Network error: \(error.localizedDescription)")
    }
    
    private func handleHTTPError(statusCode: Int, data: Data?, prompt: String) {
        var message = "Server error (Code: \(statusCode))"
        
        // Try to get error message from response
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errorMsg = json["error"] as? String {
            message = errorMsg
        }
        
        // Check for specific status codes
        switch statusCode {
        case 400:
            message = "Bad request. Please check your input."
        case 401:
            message = "Authentication failed. Check your API keys."
        case 404:
            message = "AI function not found. Please set it up in Back4App."
        case 429:
            message = "Too many requests. Please wait a moment."
        case 500...599:
            // Server error - retry if possible
            if currentRetry < maxRetries {
                currentRetry += 1
                print("⚠️ Server error. Retrying (\(currentRetry)/\(maxRetries))...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.performRequest(prompt: prompt)
                }
                return
            } else {
                message = "Server is having issues. Please try again later."
            }
        default:
            break
        }
        
        isLoading = false
        showError(message)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        print("❌ Error: \(message)")
    }
    
    // MARK: - Utility Functions
    
    /// Clear conversation history
    func clearHistory() {
        conversationHistory.removeAll()
        aiResponse = ""
        errorMessage = nil
        print("🗑️ Conversation history cleared")
    }
    
    /// Cancel current request
    func cancelRequest() {
        isLoading = false
        errorMessage = nil
        print("🚫 Request cancelled")
    }
    
    /// Get the last response
    func getLastResponse() -> String? {
        return conversationHistory.last?.response
    }
    
    /// Get conversation count
    func getConversationCount() -> Int {
        return conversationHistory.count
    }
    
    /// Export conversation as text
    func exportConversation() -> String {
        guard !conversationHistory.isEmpty else {
            return "No conversation history."
        }
        
        var text = "Fitelligence AI Conversation\n"
        text += "Generated: \(Date().formatted())\n"
        text += String(repeating: "-", count: 50) + "\n\n"
        
        for (index, entry) in conversationHistory.enumerated() {
            text += "[\(index + 1)] You: \(entry.prompt)\n"
            text += "AI: \(entry.response)\n\n"
        }
        
        return text
    }
    
    // MARK: - Validation Helpers
    
    /// Check if API is configured
    func isConfigured() -> Bool {
        return appId != "YOUR_APP_ID" && restKey != "YOUR_REST_API_KEY"
    }
    
    /// Get configuration status message
    func getConfigurationStatus() -> String {
        if appId == "YOUR_APP_ID" || restKey == "YOUR_REST_API_KEY" {
            return "⚠️ API keys not configured. Please add your Back4App credentials."
        }
        return "✅ API configured"
    }
}

