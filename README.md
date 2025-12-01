# Voice Notes Plus

A Flutter application for recording, transcribing, and managing voice notes with speech-to-text functionality.

## Features

- 🎤 **Audio Recording** - Record voice notes with high-quality audio
- 📝 **Speech-to-Text** - Real-time transcription using speech recognition
- 💾 **Local Storage** - Save notes using Hive database
- ❤️ **Like/Unlike** - Mark favorite notes
- 🔍 **Search** - Search through your notes
- 🎨 **Material 3 Design** - Modern, beautiful UI

## Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- For Windows: Visual Studio with C++ workload
- For Android: Android Studio
- For iOS: Xcode (macOS only)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/raj-aryan-official/VoiceNotesPlus.git
cd VoiceNotesPlus
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Windows
flutter run -d windows

# For Web
flutter run -d chrome

# For Android
flutter run -d android
```

## Deployment

### Vercel Deployment

**Note:** Vercel doesn't natively support Flutter builds. You'll need to:

1. Build the web app locally:
```bash
flutter build web --release
```

2. Deploy the `build/web` folder to Vercel, or use a CI/CD pipeline.

Alternatively, use GitHub Actions to build and deploy automatically.

## Project Structure

```
lib/
├── core/
│   ├── theme/          # App theme and colors
│   ├── utils/          # Utility functions
│   └── constants/      # App constants
├── features/
│   ├── splash/         # Splash screen
│   ├── home/           # Home screen
│   ├── recording/      # Recording functionality
│   ├── stt/            # Speech-to-text service
│   ├── notes/          # Notes management
│   └── liked/          # Liked notes
└── main.dart
```

## Technologies Used

- **Flutter** - UI Framework
- **Hive** - Local database
- **Provider** - State management
- **speech_to_text** - Speech recognition
- **record** - Audio recording
- **audioplayers** - Audio playback
- **path_provider** - File system access

## License

This project is licensed under the MIT License.
