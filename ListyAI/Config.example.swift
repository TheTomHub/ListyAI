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
    static let anthropicAPIKey = "your-api-key-here"

    // Claude model to use
    static let claudeModel = "claude-sonnet-4-20250514"

    // API endpoint
    static let anthropicAPIURL = "https://api.anthropic.com/v1/messages"

    // How often to send transcription chunks to Claude (in seconds)
    static let extractionInterval: TimeInterval = 10.0
}
