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
        
        // Check if API key is configured
        if restKey == "YOUR_REST_API_KEY" {
            errorMessage = "❌ REST API Key not configured. Add it in AIViewModel.swift"
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
        
        print("🚀 Sending request to: \(endpoint)")
        print("📦 Body: \(body)")
        
        do {
            // Encode body to JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Make the request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "❌ Invalid response from server"
                isLoading = false
                return
            }
            
            print("📡 Response status: \(httpResponse.statusCode)")
            
            // Try to parse error from server
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📄 Response JSON: \(json)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to get detailed error message
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorDetail = json["error"] as? String {
                    errorMessage = "❌ Server error: \(errorDetail)"
                } else if httpResponse.statusCode == 400 {
                    errorMessage = "❌ Bad Request (400): Cloud function 'aiFunction' may not exist in Back4App or has wrong parameters"
                } else if httpResponse.statusCode == 401 {
                    errorMessage = "❌ Authentication failed (401): Check your REST API Key"
                } else if httpResponse.statusCode == 404 {
                    errorMessage = "❌ Not Found (404): Cloud function 'aiFunction' doesn't exist in Back4App"
                } else {
                    errorMessage = "❌ Server error: \(httpResponse.statusCode)"
                }
                isLoading = false
                return
            }
            
            // Parse response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📄 Response JSON: \(json)")
                print("📝 Available keys: \(json.keys)")
                
                // Check what's inside "result"
                if let result = json["result"] {
                    print("🔍 Type of 'result': \(type(of: result))")
                    print("🔍 Value of 'result': \(result)")
                }
                
                // Try different response formats
                if let result = json["result"] as? String {
                    // Format 1: { "result": "text" }
                    aiResponse = result
                    print("✅ Success! (Format 1 - Direct String) Response: \(result)")
                    
                } else if let resultDict = json["result"] as? [String: Any] {
                    // Format 2: { "result": { ... } } - nested object
                    print("🔍 'result' is a dictionary with keys: \(resultDict.keys)")
                    
                    if let text = resultDict["text"] as? String {
                        // Format 2a: { "result": { "text": "..." } }
                        aiResponse = text
                        print("✅ Success! (Format 2a) Response: \(text)")
                    } else if let content = resultDict["content"] as? String {
                        // Format 2b: { "result": { "content": "..." } }
                        aiResponse = content
                        print("✅ Success! (Format 2b) Response: \(content)")
                    } else if let message = resultDict["message"] as? String {
                        // Format 2c: { "result": { "message": "..." } }
                        aiResponse = message
                        print("✅ Success! (Format 2c) Response: \(message)")
                    } else if let response = resultDict["response"] as? String {
                        // Format 2d: { "result": { "response": "..." } }
                        aiResponse = response
                        print("✅ Success! (Format 2d) Response: \(response)")
                    } else {
                        // Show all nested keys
                        print("⚠️ Nested dictionary keys: \(resultDict.keys)")
                        for (key, value) in resultDict {
                            print("  - \(key): \(type(of: value))")
                        }
                        errorMessage = "❌ Found 'result' object but couldn't find text inside. Check console."
                    }
                    
                } else if let resultArray = json["result"] as? [Any] {
                    // Format 3: { "result": [ ... ] } - array
                    print("🔍 'result' is an array with \(resultArray.count) items")
                    print("🔍 Array contents: \(resultArray)")
                    errorMessage = "❌ 'result' is an array. Check console for structure."
                    
                } else {
                    // Unknown type
                    print("⚠️ 'result' has unexpected type: \(type(of: json["result"]!))")
                    errorMessage = "❌ Unexpected response format. Check Xcode console for details."
                }
                
            } else {
                errorMessage = "❌ Failed to parse response as JSON"
                if let rawString = String(data: data, encoding: .utf8) {
                    print("📄 Raw response: \(rawString)")
                }
            }
            
        } catch {
            errorMessage = "❌ Network error: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Clear Response
    func clearResponse() {
        aiResponse = ""
        errorMessage = nil
    }
}
