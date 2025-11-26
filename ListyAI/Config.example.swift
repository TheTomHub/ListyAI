//
//  Config.example.swift
//  ListyAI
//
//  Example configuration file - Copy this to Config.swift and add your API key
//
//  Instructions:
//  1. Copy this file and rename it to "Config.swift"
//  2. Replace "your-api-key-here" with your actual Anthropic API key
//  3. Config.swift is gitignored, so your key will stay private
//

import Foundation

enum Config {
    // Get your API key from: https://console.anthropic.com/
    // First tries to get from Keychain, falls back to hardcoded value
    static var anthropicAPIKey: String {
        if let keychainKey = KeychainHelper.shared.getAPIKey(), !keychainKey.isEmpty {
            return keychainKey
        }
        return "your-api-key-here"
    }

    // Claude model to use
    static let claudeModel = "claude-sonnet-4-20250514"

    // API endpoint
    static let anthropicAPIURL = "https://api.anthropic.com/v1/messages"

    // How often to send transcription chunks to Claude (in seconds)
    static let extractionInterval: TimeInterval = 10.0

    // App metadata
    static let appVersion = "1.0"
    static let githubRepo = "https://github.com/TheTomHub/ListyAI"
    static let feedbackEmail = "feedback@listyai.app"
}
