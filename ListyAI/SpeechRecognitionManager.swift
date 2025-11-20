//
//  SpeechRecognitionManager.swift
//  ListyAI
//
//  Manages real-time speech recognition and transcription
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognitionManager: ObservableObject {
    // Published properties that the UI will observe
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String = ""

    // Speech recognition components
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        // Initialize speech recognizer for US English
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    // MARK: - Permission Handling

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Speech recognition authorized, now request microphone access
                    self.requestMicrophonePermission(completion: completion)
                case .denied:
                    self.errorMessage = "Speech recognition access denied. Please enable it in Settings."
                    completion(false)
                case .restricted:
                    self.errorMessage = "Speech recognition restricted on this device."
                    completion(false)
                case .notDetermined:
                    self.errorMessage = "Speech recognition not yet authorized."
                    completion(false)
                @unknown default:
                    self.errorMessage = "Unknown authorization status."
                    completion(false)
                }
            }
        }
    }

    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    completion(true)
                } else {
                    self.errorMessage = "Microphone access denied. Please enable it in Settings."
                    completion(false)
                }
            }
        }
    }

    // MARK: - Recording Control

    func startRecording() {
        // Check if already recording
        if isRecording {
            return
        }

        // Reset any previous session
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            return
        }

        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            return
        }

        // Configure request for real-time results
        recognitionRequest.shouldReportPartialResults = true

        // Get the input node from the audio engine
        let inputNode = audioEngine.inputNode

        // Start the recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                // Update transcribed text in real-time
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                // Stop the audio engine and clean up
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }

        // Configure the microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        // Start the audio engine
        audioEngine.prepare()

        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.transcribedText = ""
                self.errorMessage = ""
            }
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        if !isRecording {
            return
        }

        // Stop the audio engine
        audioEngine.stop()

        // End the recognition request
        recognitionRequest?.endAudio()

        // Update recording state
        isRecording = false
    }
}
