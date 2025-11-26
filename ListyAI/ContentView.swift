//
//  ContentView.swift
//  ListyAI
//
//  Main UI for recording and displaying real-time transcription with beautiful, polished design
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechManager = SpeechRecognitionManager()
    @State private var permissionsGranted = false
    @State private var showCopiedAlert = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var shareText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main Content Scroll View
                ScrollView {
                    VStack(spacing: 24) {
                        // Empty State
                        if !speechManager.isRecording && speechManager.transcribedText.isEmpty && speechManager.extractedCategories.isEmpty {
                            emptyStateView
                                .padding(.top, 60)
                        }

                        // Transcription Section
                        if !speechManager.transcribedText.isEmpty || speechManager.isRecording {
                            transcriptionSection
                        }

                        // Extracted Lists Section
                        if !speechManager.extractedCategories.isEmpty {
                            extractedListsSection
                        }

                        // Error Message
                        if !speechManager.errorMessage.isEmpty {
                            errorView
                        }
                    }
                    .padding(.bottom, 140) // Space for button
                }

                Spacer()

                // Bottom Controls
                bottomControls
            }
            .navigationTitle("List-y")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !speechManager.extractedCategories.isEmpty {
                        Button(action: clearSession) {
                            Label("Clear", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .shareSheet(isPresented: $showShareSheet, text: shareText)
            .onAppear {
                requestPermissions()
            }
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Your thought-catching assistant")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Tap and brain dump. Talk through your to-dos, ideas, shopping lists—anything fleeting")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Transcription Section

    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Transcription", systemImage: "text.bubble.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Word count
                Text("\(wordCount(speechManager.transcribedText)) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )

                if speechManager.isExtractingLists {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Extracting...")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)

            Text(speechManager.transcribedText)
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
        }
    }

    // MARK: - Extracted Lists Section

    private var extractedListsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Extracted Lists", systemImage: "list.bullet.circle.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Share Button
                Button(action: shareList) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                        Text("Share")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                }

                // Copy Markdown Button
                Button(action: copyAsMarkdown) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(showCopiedAlert ? "Copied!" : "Copy MD")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(showCopiedAlert ? Color.green : Color.purple)
                    )
                }
            }
            .padding(.horizontal)

            // Display each category
            ForEach(speechManager.extractedCategories) { category in
                CategoryCardView(category: category)
            }
        }
    }

    // MARK: - Error View

    private var errorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(speechManager.errorMessage)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
        .padding(.horizontal)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Recording Indicator
            if speechManager.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .modifier(PulseAnimation())

                    Text("Recording...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Record/Stop Button
            Button(action: toggleRecording) {
                HStack(spacing: 12) {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 28))

                    Text(speechManager.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: speechManager.isRecording ?
                                    [Color.red, Color.red.opacity(0.8)] :
                                    [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: (speechManager.isRecording ? Color.red : Color.blue).opacity(0.3), radius: 10, x: 0, y: 5)
                )
            }
            .padding(.horizontal, 20)

            // Example Suggestions (only when not recording and no content)
            if !speechManager.isRecording && speechManager.transcribedText.isEmpty {
                VStack(spacing: 8) {
                    Text("Try:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ExampleChip(text: "List your morning to-dos")
                        ExampleChip(text: "Plan your grocery run")
                    }
                    HStack(spacing: 12) {
                        ExampleChip(text: "Capture meeting actions")
                        ExampleChip(text: "Brain dump random ideas")
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 140)
            .offset(y: -60)
        )
    }

    // MARK: - Actions

    private func toggleRecording() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if speechManager.isRecording {
            speechManager.stopRecording()
        } else {
            if permissionsGranted {
                speechManager.startRecording()
            } else {
                requestPermissions()
            }
        }
    }

    private func requestPermissions() {
        speechManager.requestPermissions { granted in
            permissionsGranted = granted
        }
    }

    private func clearSession() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        speechManager.transcribedText = ""
        speechManager.extractedCategories = []
        speechManager.errorMessage = ""
    }

    private func shareList() {
        shareText = ShareHelper.formatForSharing(categories: speechManager.extractedCategories)
        showShareSheet = true

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func copyAsMarkdown() {
        let markdown = ShareHelper.formatAsMarkdown(categories: speechManager.extractedCategories)
        UIPasteboard.general.string = markdown

        // Show success feedback
        withAnimation {
            showCopiedAlert = true
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }

    private func wordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
}

// MARK: - Category Card View

struct CategoryCardView: View {
    let category: ListCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Category Header
            HStack(spacing: 8) {
                Text(category.emoji)
                    .font(.title2)

                Text(category.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                // Item count badge
                Text("\(category.items.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(category.color)
                    )
            }

            // Divider
            Rectangle()
                .fill(category.color.opacity(0.3))
                .frame(height: 2)

            // Category Items
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(category.items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(item)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: category.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Example Chip View

struct ExampleChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
    }
}

// MARK: - Pulse Animation

struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    ContentView()
}
