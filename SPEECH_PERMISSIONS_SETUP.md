# Speech Recognition Permissions Setup

To enable voice input functionality in the app, you need to add privacy permissions for microphone and speech recognition access.

## Required Privacy Permissions

Add the following keys to your app's **Target Settings > Info**:

### 1. Privacy - Microphone Usage Description
- **Key**: `NSMicrophoneUsageDescription`
- **Value**: "This app needs microphone access to enable voice input for terminal commands."

### 2. Privacy - Speech Recognition Usage Description  
- **Key**: `NSSpeechRecognitionUsageDescription`
- **Value**: "This app uses speech recognition to convert your voice input into terminal commands."

## How to Add in Xcode

1. Open the Xcode project
2. Select your app target in the project navigator
3. Go to the **Info** tab
4. Click the **+** button to add a new entry
5. Add both privacy keys with their descriptions

## Alternative: Manual Info.plist

If you prefer to edit the Info.plist file directly, add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to enable voice input for terminal commands.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to convert your voice input into terminal commands.</string>
```

## Features Implemented

✅ **SpeechRecognitionManager**: Handles all speech recognition logic  
✅ **VoiceInputView**: User interface for voice input with visual feedback  
✅ **SessionDetailView Integration**: Voice input is now available in terminal sessions  
✅ **Permission Handling**: Automatic permission requests and status indicators  
✅ **Real-time Feedback**: Shows listening state and recognized text  
✅ **Error Handling**: Graceful handling of permission denials and errors  

## Usage

1. Open any terminal session in the app
2. Tap the "Voice Input" button (microphone icon)
3. Grant permissions when prompted
4. Speak your terminal command
5. Tap "Stop Recording" when done
6. Review the recognized text and tap "Send Command"

The voice input feature supports all standard terminal commands and will automatically send them to the active terminal session.