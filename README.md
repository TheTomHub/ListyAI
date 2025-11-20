# List-y

An iOS app that extracts lists from spoken conversations in real-time using AI.

## Overview

List-y is a simple, powerful iOS app that:
- Records and transcribes speech in real-time using Apple's Speech framework
- Extracts list items (pros, cons, features, ideas, action items) using Claude API
- Displays categorized lists as you speak in real-time
- Allows exporting to clipboard in markdown format

## Current Status: Step 3 Complete ✅ - Launch Ready!

**Implemented Features:**

**Step 1 - Basic Recording & Transcription:**
- Single screen with big "Record" button
- Real-time speech transcription using Apple's Speech framework
- Audio capture with AVAudioEngine
- Live display of transcribed text
- Stop button to end recording
- Permission handling for microphone and speech recognition

**Step 2 - Claude API Integration & List Extraction:**
- Claude API integration using claude-sonnet-4-20250514 model
- Automatic list extraction every 10 seconds during recording
- Smart categorization (Pros, Cons, Suggestions, Action Items, etc.)
- Real-time display of extracted lists
- "Copy All Lists" button for exporting as markdown
- Secure API key storage (gitignored Config.swift)

**Step 3 - Beautiful UI & Sharing (Launch Ready!):**
- Polished navigation bar with "List-y" branding
- Beautiful empty state with tagline "Turn conversations into action"
- Color-coded category cards with emojis (✅ Pros, ❌ Cons, 💡 Ideas, etc.)
- Word count badge showing transcription progress
- Settings screen with Keychain-based API key storage
- Native iOS share sheet integration
- Copy as Markdown for developers
- Haptic feedback for all interactions
- Clear session button to start fresh
- Gradient buttons with shadows
- Smooth animations and transitions
- Category-specific colors (green for pros, red for cons, purple for suggestions)
- Item count badges on category cards

## Project Structure

```
ListyAI/
├── ListyAI/
│   ├── ListyAIApp.swift              # Main app entry point
│   ├── ContentView.swift              # Main UI with beautiful design
│   ├── SettingsView.swift             # Settings screen
│   ├── SpeechRecognitionManager.swift # Speech recognition & list extraction
│   ├── ClaudeAPIService.swift         # Claude API integration
│   ├── Models.swift                   # Data models with color coding
│   ├── KeychainHelper.swift           # Secure API key storage
│   ├── ShareHelper.swift              # Share sheet integration
│   ├── Config.swift                   # API configuration (gitignored)
│   ├── Config.example.swift           # Example config file
│   ├── Info.plist                     # Required permissions
│   └── Assets.xcassets/               # App assets and icon
├── .gitignore                         # Git ignore file
└── ListyAI.xcodeproj/                 # Xcode project file
```

## Setup Instructions

### Requirements
- macOS with Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Apple Developer account (for device deployment)
- **Anthropic API key** (get one at https://console.anthropic.com/)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ListyAI
   ```

2. **Configure API Key (Two Options):**

   **Option A - Using the Settings Screen (Recommended):**
   - Run the app
   - Tap the gear icon ⚙️ in the top right
   - Enter your Anthropic API key in the Settings screen
   - Tap "Save API Key"
   - Your key is securely stored in iOS Keychain

   **Option B - Using Config.swift:**
   - Open `ListyAI/Config.swift`
   - Replace `"your-api-key-here"` with your Anthropic API key
   - Save the file (it's gitignored so your key stays private)

3. **Open the project in Xcode:**
   ```bash
   open ListyAI.xcodeproj
   ```

4. **Select your target device:**
   - Choose a physical iPhone or iPad (recommended for best speech recognition)
   - Or use the iOS Simulator (speech recognition has limitations)

5. **Run the app:**
   - Press `Cmd + R` or click the Play button
   - The app will request microphone and speech recognition permissions
   - Grant both permissions when prompted

6. **Test the app:**
   - Tap the gradient "Start Recording" button
   - Start speaking naturally about lists (e.g., "Let me list the pros and cons...")
   - Watch transcription appear in real-time with word count
   - Every 10 seconds, Claude will extract and categorize list items
   - Beautiful color-coded cards appear below with emojis
   - Tap "Share" to use iOS native share sheet
   - Tap "Copy MD" to copy as markdown for developers
   - Tap "Stop Recording" to end the session
   - Tap the trash icon to clear and start fresh

## How It Works

### SpeechRecognitionManager
The core speech recognition and list extraction logic (`SpeechRecognitionManager.swift:1`):
- Manages AVAudioEngine for audio capture
- Uses SFSpeechRecognizer for real-time transcription
- Publishes transcription updates via @Published properties
- Automatically sends transcription to Claude API every 10 seconds
- Merges and deduplicates extracted list items
- Handles permission requests and error states

### ClaudeAPIService
API integration service (`ClaudeAPIService.swift:1`):
- Makes HTTP requests to Claude API (claude-sonnet-4-20250514)
- Uses custom system prompt for list extraction
- Parses JSON responses containing categorized lists
- Handles API errors and malformed responses

### ContentView
The UI is built with SwiftUI (`ContentView.swift:1`):
- Clean, scrollable interface showing transcription and lists
- Large, accessible Record/Stop button
- Real-time transcription display with extraction status
- Category cards displaying extracted list items
- "Copy All Lists" button for markdown export
- Error message handling

## Permissions

The app requires two permissions (configured in `Info.plist:1`):

1. **Microphone Access (NSMicrophoneUsageDescription)**
   - Required to capture audio

2. **Speech Recognition (NSSpeechRecognitionUsageDescription)**
   - Required to transcribe audio to text

## Screenshot-Worthy Features

✨ **Every screen is designed to look beautiful:**

1. **Empty State**: Elegant waveform icon with inspiring tagline
2. **Recording**: Gradient button with smooth pulse animation
3. **Transcription**: Clean card with word count badge
4. **Extracted Lists**: Color-coded cards with emojis and shadows
   - ✅ Green for Pros
   - ❌ Red for Cons
   - 💡 Purple for Ideas/Suggestions
   - 📋 Orange for Action Items
5. **Settings**: Clean form with secure Keychain storage
6. **Share Sheet**: Native iOS sharing with formatted text

## Future Enhancements

**Next Steps:**
- Add list history/session saving
- Export directly to Notes app
- Voice feedback when lists are detected
- Adjustable extraction interval in settings
- Support for multiple languages

**Future Ideas:**
- iCloud sync across devices
- Siri Shortcuts integration
- Apple Watch companion app
- Offline mode with local list extraction
- Team sharing features
- Custom category templates

## Technical Details

- **Language:** Swift 5.0
- **Framework:** SwiftUI
- **iOS Version:** 16.0+
- **Architecture:** MVVM pattern with ObservableObject
- **Speech Recognition:** Apple Speech framework (SFSpeechRecognizer)
- **Audio:** AVFoundation framework (AVAudioEngine)
- **AI Model:** Claude Sonnet 4 (claude-sonnet-4-20250514)
- **API Integration:** Direct HTTP calls using URLSession
- **Data Format:** JSON for API requests/responses

## Known Limitations

- Speech recognition requires internet connection for best results
- iOS Simulator has limited speech recognition capabilities
- Transcription accuracy depends on audio quality and accent
- List extraction requires valid Anthropic API key
- API calls are made every 10 seconds (may incur costs based on usage)
- App currently stores only current session (no persistence yet)
- List extraction quality depends on how clearly lists are spoken

## Example Usage

Try speaking something like this:

> "Let me think about the pros and cons of moving to a new city. On the pro side, there's better job opportunities, more cultural activities, and a change of scenery. For the cons, it's expensive, I'd be far from family, and I don't know anyone there. I should also make a list of action items: research neighborhoods, calculate moving costs, and visit the city for a weekend."

The app will extract:

**Pros:**
- Better job opportunities
- More cultural activities
- Change of scenery

**Cons:**
- Expensive
- Far from family
- Don't know anyone there

**Action Items:**
- Research neighborhoods
- Calculate moving costs
- Visit the city for a weekend
