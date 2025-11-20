//
//  SettingsView.swift
//  ListyAI
//
//  Settings screen for API key and app information
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var apiKey: String = ""
    @State private var showSavedAlert = false
    @State private var isAPIKeyVisible = false

    var body: some View {
        NavigationView {
            Form {
                // API Key Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anthropic API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            if isAPIKeyVisible {
                                TextField("sk-ant-...", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("sk-ant-...", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }

                            Button(action: {
                                isAPIKeyVisible.toggle()
                            }) {
                                Image(systemName: isAPIKeyVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }

                        Link("Get API Key →", destination: URL(string: "https://console.anthropic.com/")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    Button(action: saveAPIKey) {
                        HStack {
                            Spacer()
                            Text(showSavedAlert ? "✓ Saved!" : "Save API Key")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(showSavedAlert ? Color.green : Color.blue)
                } header: {
                    Text("API Configuration")
                } footer: {
                    Text("Your API key is stored securely in iOS Keychain and never shared.")
                        .font(.caption)
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Config.appVersion)
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: Config.githubRepo)!) {
                        HStack {
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "mailto:\(Config.feedbackEmail)")!) {
                        HStack {
                            Text("Send Feedback")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Built by Tom")
                        Text("Open source on GitHub")
                        Text("\nList-y turns conversations into actionable lists using AI.")
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }

                // Privacy Section
                Section {
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("List-y doesn't store your recordings. Audio is transcribed locally on your device using Apple's Speech framework. Only the text transcription is sent to Claude API for list extraction. No data is stored on our servers.")
                        .font(.caption)
                        .padding(.top, 4)
                }

                // Advanced Section
                Section {
                    HStack {
                        Text("Model")
                        Spacer()
                        Text("Claude Sonnet 4")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }

                    HStack {
                        Text("Extraction Interval")
                        Spacer()
                        Text("\(Int(Config.extractionInterval))s")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Advanced")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadAPIKey()
            }
        }
    }

    private func loadAPIKey() {
        if let savedKey = KeychainHelper.shared.getAPIKey() {
            apiKey = savedKey
        }
    }

    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedKey.isEmpty {
            _ = KeychainHelper.shared.saveAPIKey(trimmedKey)

            // Show success feedback
            withAnimation {
                showSavedAlert = true
            }

            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Reset after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSavedAlert = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
