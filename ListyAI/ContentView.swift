//
//  ContentView.swift
//  ListyAI
//
//  Main UI for recording and displaying real-time transcription
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechManager = SpeechRecognitionManager()
    @State private var permissionsGranted = false
    @State private var showCopiedAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // App Title
            Text("List-y")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 20)
                .padding(.bottom, 20)

            // Main Content Scroll View
            ScrollView {
                VStack(spacing: 20) {
                    // Transcription Display
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Transcription")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)

                            if speechManager.isExtractingLists {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Extracting lists...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)

                        Text(speechManager.transcribedText.isEmpty ? "Tap Record to start transcribing..." : speechManager.transcribedText)
                            .font(.system(size: 16))
                            .foregroundColor(speechManager.transcribedText.isEmpty ? .gray : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
                    }

                    // Extracted Lists Display
                    if !speechManager.extractedCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Extracted Lists")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)

                                Spacer()

                                // Copy All Button
                                Button(action: {
                                    copyAllLists()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 12))
                                        Text(showCopiedAlert ? "Copied!" : "Copy All")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(showCopiedAlert ? Color.green : Color.blue)
                                    )
                                }
                            }
                            .padding(.horizontal)

                            // Display each category
                            ForEach(speechManager.extractedCategories) { category in
                                CategoryCardView(category: category)
                            }
                        }
                        .padding(.top, 10)
                    }

                    // Error Message
                    if !speechManager.errorMessage.isEmpty {
                        Text(speechManager.errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }

            Spacer()

            // Bottom Controls
            VStack(spacing: 12) {
                // Recording Indicator
                if speechManager.isRecording {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .opacity(0.8)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: speechManager.isRecording)

                        Text("Recording...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }

                // Record/Stop Button
                Button(action: {
                    if speechManager.isRecording {
                        speechManager.stopRecording()
                    } else {
                        if permissionsGranted {
                            speechManager.startRecording()
                        } else {
                            requestPermissions()
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 32))

                        Text(speechManager.isRecording ? "Stop" : "Record")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(speechManager.isRecording ? Color.red : Color.blue)
                    )
                    .shadow(color: speechManager.isRecording ? .red.opacity(0.3) : .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            requestPermissions()
        }
    }

    private func requestPermissions() {
        speechManager.requestPermissions { granted in
            permissionsGranted = granted
            if granted && speechManager.isRecording {
                // Permissions were granted, but we're not auto-starting
                // User needs to tap Record button
            }
        }
    }

    private func copyAllLists() {
        let markdown = formatListsAsMarkdown()
        UIPasteboard.general.string = markdown

        // Show copied alert
        showCopiedAlert = true

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedAlert = false
        }
    }

    private func formatListsAsMarkdown() -> String {
        var markdown = "# Extracted Lists\n\n"

        for category in speechManager.extractedCategories {
            markdown += "## \(category.name)\n\n"

            for item in category.items {
                markdown += "- \(item)\n"
            }

            markdown += "\n"
        }

        return markdown
    }
}

// MARK: - Category Card View

struct CategoryCardView: View {
    let category: ListCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Name
            Text(category.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Category Items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(category.items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)

                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
