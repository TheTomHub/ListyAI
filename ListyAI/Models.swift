//
//  Models.swift
//  ListyAI
//
//  Data models for list extraction and categorization
//

import Foundation

// MARK: - List Category Model

struct ListCategory: Identifiable, Codable {
    let id: UUID
    let name: String
    var items: [String]

    init(id: UUID = UUID(), name: String, items: [String]) {
        self.id = id
        self.name = name
        self.items = items
    }
}

// MARK: - Claude API Response Models

struct ClaudeAPIResponse: Codable {
    let categories: [CategoryResponse]
}

struct CategoryResponse: Codable {
    let name: String
    let items: [String]
}

// MARK: - Claude API Request Models

struct ClaudeMessageRequest: Codable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessage]
    let system: String?

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
        case system
    }
}

struct ClaudeMessage: Codable {
    let role: String
    let content: String
}

struct ClaudeAPIMessageResponse: Codable {
    let content: [ClaudeContent]
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case stopReason = "stop_reason"
    }
}

struct ClaudeContent: Codable {
    let type: String
    let text: String?
}
