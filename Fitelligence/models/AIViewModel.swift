import Foundation

class AIViewModel: ObservableObject {
    @Published var userPrompt = ""
    @Published var aiResponse = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    func sendPrompt() {
        guard !userPrompt.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        aiResponse = ""

        let url = URL(string: "https://parseapi.back4app.com/functions/aiFunction")!   // <-- change name if needed

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // REQUIRED HEADERS
        request.addValue("<APP_ID>", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("<REST_KEY>", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // BODY
        let body: [String: Any] = ["prompt": userPrompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            // Back4App Cloud Functions return: { "result": ... }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? String {
                DispatchQueue.main.async {
                    self.aiResponse = result
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response."
                }
            }
        }.resume()
    }
}


