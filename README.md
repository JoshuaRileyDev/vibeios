# VibeIOS - Terminal Session Management for iOS

VibeIOS is a powerful iOS application that provides remote terminal session management through the VibeTunnel API. Built with SwiftUI, this app enables developers to manage coding projects, create terminal sessions, and interact with AI agents like Claude Code directly from their iPhone or iPad.

## 🎯 Purpose

VibeIOS serves as a mobile interface for remote development environments, allowing developers to:
- Manage multiple coding projects from their iOS device
- Create and monitor terminal sessions in project directories
- Launch Claude Code with automatic permission handling
- Parse real-time AI session status with countdown timers and token tracking
- Execute commands and view terminal output with enhanced formatting
- Use voice input for hands-free command execution

## 🚀 Current Features

### Project Management
- **Create Projects**: Set up new projects with custom names and working directories
- **Project Overview**: View all projects with running session counts
- **Session Tracking**: See active terminal sessions per project
- **Directory Association**: Link projects to specific working directories

### Terminal Session Management
- **Session Creation**: Spawn new terminal sessions with customizable commands
- **Real-time Monitoring**: Track session status (running, exited, stopped)
- **Auto-start Claude**: Automatically launch Claude Code when creating sessions
- **Permission Bypass**: Optional `--dangerously-skip-permissions` flag support
- **Session Details**: View individual session info, output, and send commands

### AI Integration & Status Detection
- **Claude Code Launch**: One-tap Claude Code activation with custom prompts
- **Session State Parsing**: Real-time detection of AI running state
- **Countdown Timers**: Display elapsed time when AI is actively running
- **Token Tracking**: Show token consumption during AI sessions
- **Output Processing**: Parse terminal output to detect AI activity patterns
- **Status Indicators**: Visual feedback for idle, running, and active AI states

### Voice Input Support
- **Speech Recognition**: Convert voice to text for command input
- **Voice Commands**: Send voice-converted commands to terminal sessions
- **Hands-free Operation**: Execute terminal commands without typing

### Advanced Terminal Features
- **Enhanced Output**: Syntax-highlighted terminal output with line numbers
- **Claude Code Detection**: Specialized formatting for Claude Code output
- **ANSI Processing**: Clean removal of terminal escape codes
- **Unicode Normalization**: Proper handling of special characters
- **Real-time Updates**: 5-second refresh intervals for session states

## 🏗️ Architecture

### Core Components

```
VibeIOS App Structure
├── vibeiosApp.swift           # App entry point and configuration
├── ContentView.swift          # Root navigation view
├── Models.swift               # Data models (Project, Session, etc.)
├── DataStore.swift            # Centralized state management
├── VibeTunnelAPI.swift        # API service and terminal output parsing
├── ProjectsListView.swift     # Main projects overview
├── ProjectDetailView.swift    # Individual project management
├── CreateProjectView.swift    # New project creation
├── CreateAgentView.swift      # New session creation with Claude integration
├── SessionDetailView.swift    # Terminal session interface
├── SettingsView.swift         # API configuration
├── VoiceInputView.swift       # Speech recognition interface
└── SpeechRecognitionManager.swift # Voice processing logic
```

### Data Models

```swift
Project
├── id: UUID
├── name: String
├── workingDirectory: String
└── createdDate: Date

Session (from VibeTunnel API)
├── id: String
├── command: String
├── workingDir: String
├── status: String
├── exitCode: Int?
├── startedAt: String
├── lastModified: String
└── pid: Int?

SessionState (AI Detection)
├── isAIRunning: Bool
├── runningSeconds: Int?
├── tokenCount: Int?
└── isIdle: Bool
```

### Key Technologies

- **SwiftUI**: Modern iOS UI framework
- **Combine**: Reactive programming for state management
- **URLSession**: HTTP API communication
- **Speech Framework**: Voice input processing
- **UserDefaults**: Persistent settings storage
- **Regular Expressions**: Terminal output parsing
- **JSON**: API data serialization

## 🔗 VibeTunnel API Integration

The app integrates with VibeTunnel server providing:

### Session Management
- **Create Sessions**: POST `/api/sessions` - Start new terminal sessions
- **List Sessions**: GET `/api/sessions` - Retrieve all active sessions
- **Session Snapshot**: GET `/api/sessions/{id}/snapshot` - Get terminal output
- **Send Input**: POST `/api/sessions/{id}/input` - Execute commands
- **Kill Session**: DELETE `/api/sessions/{id}` - Terminate sessions

### Advanced Features
- **Health Check**: GET `/api/health` - Server connectivity status
- **File System**: GET `/api/fs/browse` - Directory browsing
- **Ngrok Tunneling**: Secure tunnel management

### Terminal Output Parsing

The app includes sophisticated parsing logic to detect:
- **Claude Code Status**: Running vs idle states
- **Time Tracking**: Elapsed seconds from terminal timestamps
- **Token Counting**: AI token consumption tracking
- **ANSI Cleanup**: Terminal escape sequence removal
- **Unicode Handling**: Proper character normalization

## 📱 Requirements

- iOS 15.0 or later
- iPhone or iPad
- Internet connection to VibeTunnel server
- Microphone access (for voice input)

## 🛠️ Development Setup

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/vibeios.git
cd vibeios
```

2. **Open in Xcode:**
```bash
open vibeios.xcodeproj
```

3. **Configure VibeTunnel connection:**
   - Run the app
   - Go to Settings
   - Enter your VibeTunnel server URL and credentials

4. **Enable voice input (optional):**
   - Grant microphone permissions when prompted
   - See `SPEECH_PERMISSIONS_SETUP.md` for details

## ⚙️ Configuration

### VibeTunnel Server Setup
1. Start your VibeTunnel server
2. Note the server URL (e.g., `http://localhost:8080`)
3. Configure authentication if required
4. Update app settings with connection details

### Claude Code Integration
- Automatic Claude Code launching when creating sessions
- Configurable permission bypass flag
- Custom prompt support through quick actions
- Real-time session monitoring and status detection

## 🎨 User Interface

### Projects List
- Clean card-based layout showing all projects
- Running session indicators with real-time counts
- Quick access to project details and settings
- Create new project button

### Project Detail View  
- Active session list with AI status indicators
- Session creation with Claude auto-start options
- Real-time session state updates every 5 seconds
- Visual status indicators (running, idle, AI active)

### Session Detail View
- Full terminal output with syntax highlighting
- Command input with voice recognition support
- Claude Code quick actions and custom prompts
- Real-time output refresh and ANSI processing

### Settings Panel
- VibeTunnel server configuration
- Authentication credentials management
- Connection status monitoring
- Voice input preferences

## 🔧 Advanced Features

### AI Session Detection
The app uses advanced pattern matching to detect:
- Claude Code running states from terminal output
- Timestamp parsing from JSON-formatted terminal data
- Token consumption tracking during AI interactions
- Session idle vs active state determination

### Voice Input System
- Real-time speech-to-text conversion
- Command execution from voice input
- Error handling for recognition failures
- Seamless integration with terminal interface

### Terminal Output Processing
- ANSI escape sequence removal
- Unicode character normalization
- JSON timestamp extraction
- Syntax highlighting for different output types
- Line numbering and enhanced readability

## 🚧 Current Status

### ✅ Completed Features
- Complete SwiftUI interface
- VibeTunnel API integration
- Project and session management
- Claude Code auto-start functionality
- AI session state detection and monitoring
- Voice input for terminal commands
- Enhanced terminal output formatting
- Real-time session status updates
- Settings management with persistent storage

### 🔄 In Development
- Additional voice command shortcuts
- Enhanced error handling and retry logic
- Improved offline mode capabilities
- Advanced session filtering and search

### 📋 Future Enhancements
- Push notifications for session events
- Session sharing and collaboration
- Custom Claude Code templates
- Advanced terminal emulation features
- File system browsing and editing

## 🤝 Contributing

We welcome contributions! Please:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes with proper documentation**
4. **Add comprehensive comments to new code**
5. **Test thoroughly on iOS devices**
6. **Submit a pull request**

### Code Style Guidelines
- Use clear, descriptive variable and function names
- Add comprehensive comments explaining complex logic
- Follow SwiftUI best practices
- Maintain consistent formatting and structure
- Document all public APIs and complex algorithms

## 📚 Documentation

### Code Documentation
All Swift files include comprehensive comments explaining:
- Class and struct purposes
- Complex algorithm implementations
- API integration details
- UI component functionality
- State management patterns

### API Documentation
- VibeTunnel API endpoint documentation
- Request/response format specifications
- Error handling procedures
- Authentication requirements

## 🔍 Troubleshooting

### Common Issues

**Connection Problems:**
- Verify VibeTunnel server is running
- Check network connectivity
- Validate server URL and credentials
- Review server logs for errors

**Voice Input Issues:**
- Ensure microphone permissions are granted
- Check device microphone functionality
- Verify Speech Recognition availability
- Review privacy settings

**Session Creation Failures:**
- Confirm working directory exists
- Validate command syntax
- Check server capacity and resources
- Review session creation logs

## 📄 License

[License details to be added]

## 📞 Support

For questions or support:
- **GitHub Issues**: Create an issue in the repository
- **Documentation**: Check the code comments and this README
- **VibeTunnel Setup**: Refer to VibeTunnel documentation
- **iOS Development**: Apple Developer documentation

---

**VibeIOS** - Professional terminal session management with AI integration for iOS 🚀📱