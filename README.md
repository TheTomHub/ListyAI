# List-y

An iOS app that extracts lists from spoken conversations in real-time using AI.

## Overview

List-y is a simple, powerful iOS app that:
- Records and transcribes speech in real-time using Apple's Speech framework
- Will extract list items (pros, cons, features, ideas, action items) using Claude API
- Displays categorized lists as you speak
- Allows exporting to clipboard or Notes

## Current Status: Step 1 Complete ✅

**Implemented Features:**
- Single screen with big "Record" button
- Real-time speech transcription using Apple's Speech framework
- Audio capture with AVAudioRecorder
- Live display of transcribed text
- Stop button to end recording
- Permission handling for microphone and speech recognition

## Project Structure

```
ListyAI/
├── ListyAI/
│   ├── ListyAIApp.swift              # Main app entry point
│   ├── ContentView.swift              # Main UI with record button
│   ├── SpeechRecognitionManager.swift # Handles speech recognition
│   ├── Info.plist                     # Required permissions
│   └── Assets.xcassets/               # App assets
└── ListyAI.xcodeproj/                 # Xcode project file
```

## Setup Instructions

### Requirements
- macOS with Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Apple Developer account (for device deployment)

### Getting Started

1. **Open the project in Xcode:**
   ```bash
   open ListyAI.xcodeproj
   ```

2. **Select your target device:**
   - Choose a physical iPhone or iPad (recommended for best speech recognition)
   - Or use the iOS Simulator (speech recognition has limitations)

3. **Run the app:**
   - Press `Cmd + R` or click the Play button
   - The app will request microphone and speech recognition permissions
   - Grant both permissions when prompted

4. **Test the app:**
   - Tap the big blue "Record" button
   - Start speaking
   - Watch your words appear in real-time in the transcription area
   - Tap the red "Stop" button to end recording

## How It Works

### SpeechRecognitionManager
The core speech recognition logic is in `SpeechRecognitionManager.swift:1`:
- Manages AVAudioEngine for audio capture
- Uses SFSpeechRecognizer for transcription
- Publishes real-time transcription updates via @Published properties
- Handles permission requests and error states

### ContentView
The UI is built with SwiftUI in `ContentView.swift:1`:
- Clean, minimal interface focused on recording
- Large, accessible Record/Stop button
- Real-time transcription display
- Error message handling

## Permissions

The app requires two permissions (configured in `Info.plist:1`):

1. **Microphone Access (NSMicrophoneUsageDescription)**
   - Required to capture audio

2. **Speech Recognition (NSSpeechRecognitionUsageDescription)**
   - Required to transcribe audio to text

## Next Steps

**Step 2:** Add Claude API integration
- Send transcription chunks every 5-10 seconds to Claude
- Extract list items from conversations
- Categorize lists (pros, cons, features, ideas, action items)

**Step 3:** Enhanced UI
- Display categorized lists in real-time
- Add export functionality (clipboard, Notes app)
- Improve visual design

## Technical Details

- **Language:** Swift 5.0
- **Framework:** SwiftUI
- **iOS Version:** 16.0+
- **Architecture:** MVVM pattern with ObservableObject
- **Speech Recognition:** Apple Speech framework
- **Audio:** AVFoundation framework

## Known Limitations

- Speech recognition requires internet connection for best results
- iOS Simulator has limited speech recognition capabilities
- Transcription accuracy depends on audio quality and accent
- App currently stores only current session (no persistence)
