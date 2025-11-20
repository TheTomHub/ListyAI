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

    var body: some View {
        VStack(spacing: 30) {
            // App Title
            Text("List-y")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 60)

            Spacer()

            // Transcription Display
            ScrollView {
                Text(speechManager.transcribedText.isEmpty ? "Tap Record to start transcribing..." : speechManager.transcribedText)
                    .font(.system(size: 18))
                    .foregroundColor(speechManager.transcribedText.isEmpty ? .gray : .primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)

            // Error Message
            if !speechManager.errorMessage.isEmpty {
                Text(speechManager.errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

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
            .padding(.bottom, 60)

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
                .padding(.bottom, 20)
            }
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
}

#Preview {
    ContentView()
}
