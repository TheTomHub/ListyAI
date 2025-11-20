//
//  ClaudeAPIService.swift
//  ListyAI
//
//  Service for interacting with Claude API to extract lists from transcribed text
//

import Foundation

class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private let systemPrompt = """
    You are a list extraction assistant. Analyze the following conversation segment and extract ONLY items that are part of lists (pros, cons, features, suggestions, action items, ideas, etc.).

    Return a JSON object with this structure:
    {
      "categories": [
        {
          "name": "Pros",
          "items": ["item 1", "item 2"]
        },
        {
          "name": "Suggestions",
          "items": ["item 1", "item 2"]
        }
      ]
    }

    Rules:
    - Only extract clear list items (things enumerated, compared, or presented as options)
    - Ignore small talk, narrative, and non-list content
    - Auto-detect category names based on context
    - If no lists found, return empty categories array
    - Be concise - capture the essence of each item in 5-10 words max
    """

    private init() {}

    // MARK: - Extract Lists from Text

    func extractLists(from text: String) async throws -> [ListCategory] {
        guard !text.isEmpty else {
            return []
        }

        // Create the API request
        let request = try createAPIRequest(for: text)

        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Parse the response
        let apiResponse = try JSONDecoder().decode(ClaudeAPIMessageResponse.self, from: data)

        // Extract text from response
        guard let responseText = apiResponse.content.first?.text else {
            throw APIError.noContent
        }

        // Parse the JSON response
        return try parseListResponse(responseText)
    }

    // MARK: - Create API Request

    private func createAPIRequest(for text: String) throws -> URLRequest {
        guard let url = URL(string: Config.anthropicAPIURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let messageRequest = ClaudeMessageRequest(
            model: Config.claudeModel,
            maxTokens: 1024,
            messages: [
                ClaudeMessage(role: "user", content: text)
            ],
            system: systemPrompt
        )

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(messageRequest)

        return request
    }

    // MARK: - Parse Response

    private func parseListResponse(_ jsonString: String) throws -> [ListCategory] {
        // Try to extract JSON from markdown code blocks if present
        let cleanedJSON = extractJSON(from: jsonString)

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw APIError.invalidJSON
        }

        let response = try JSONDecoder().decode(ClaudeAPIResponse.self, from: jsonData)

        // Convert to ListCategory models
        return response.categories.map { category in
            ListCategory(name: category.name, items: category.items)
        }
    }

    // MARK: - Helper Methods

    private func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        let pattern = "```json\\s*([\\s\\S]*?)```|```([\\s\\S]*?)```"

        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            // Get the captured group (either group 1 or 2)
            if let range1 = Range(match.range(at: 1), in: text), !text[range1].isEmpty {
                return String(text[range1])
            } else if let range2 = Range(match.range(at: 2), in: text) {
                return String(text[range2])
            }
        }

        // If no code blocks, return as is
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Error Types

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case noContent
        case invalidJSON

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from API"
            case .httpError(let statusCode, let message):
                return "HTTP \(statusCode): \(message)"
            case .noContent:
                return "No content in API response"
            case .invalidJSON:
                return "Could not parse JSON response"
            }
        }
    }
}
