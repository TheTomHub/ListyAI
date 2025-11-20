//
//  Models.swift
//  ListyAI
//
//  Data models for list extraction and categorization
//

import Foundation
import SwiftUI

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

    // MARK: - UI Helpers

    var emoji: String {
        let lowercasedName = name.lowercased()

        // Match common category types
        if lowercasedName.contains("pro") {
            return "✅"
        } else if lowercasedName.contains("con") {
            return "❌"
        } else if lowercasedName.contains("suggestion") || lowercasedName.contains("idea") {
            return "💡"
        } else if lowercasedName.contains("action") || lowercasedName.contains("todo") || lowercasedName.contains("task") {
            return "📋"
        } else if lowercasedName.contains("feature") {
            return "⭐️"
        } else if lowercasedName.contains("question") {
            return "❓"
        } else if lowercasedName.contains("risk") || lowercasedName.contains("concern") {
            return "⚠️"
        } else if lowercasedName.contains("benefit") || lowercasedName.contains("advantage") {
            return "🎯"
        } else {
            return "📝"
        }
    }

    var color: Color {
        let lowercasedName = name.lowercased()

        // Color coding based on category type
        if lowercasedName.contains("pro") || lowercasedName.contains("benefit") || lowercasedName.contains("advantage") {
            return .green
        } else if lowercasedName.contains("con") || lowercasedName.contains("risk") || lowercasedName.contains("concern") {
            return .red
        } else if lowercasedName.contains("suggestion") || lowercasedName.contains("idea") {
            return .purple
        } else if lowercasedName.contains("action") || lowercasedName.contains("todo") || lowercasedName.contains("task") {
            return .orange
        } else if lowercasedName.contains("feature") {
            return .blue
        } else if lowercasedName.contains("question") {
            return .yellow
        } else {
            return .gray
        }
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
