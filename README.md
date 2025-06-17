# VibeIOS - AI Agent Management for iOS

VibeIOS is a powerful iOS application designed to enable Vibe coders to manage their development projects and AI agents directly from their iPhone or iPad. Built with SwiftUI, this app provides an intuitive interface for orchestrating AI-powered coding assistants on the go.

## 🎯 Purpose

VibeIOS serves as the mobile companion for the Vibe development ecosystem, allowing developers to:
- Manage multiple coding projects from their iOS device
- Control and monitor AI agents assigned to different projects
- Send prompts and receive responses from AI coding assistants
- Track agent progress and status in real-time
- Maintain development workflows while away from their desktop

## 🚀 Features

### Project Management
- **Create Projects**: Set up new projects with custom names and working directories
- **Project Overview**: View all projects with at-a-glance statistics
- **Agent Tracking**: See how many agents are assigned and running per project
- **Directory Management**: Associate each project with specific working directories

### AI Agent Control
- **Agent Creation**: Spawn new AI agents with custom names and descriptions
- **Lifecycle Management**: Start, stop, and delete agents as needed
- **Real-time Status**: Monitor agent states (idle, running, completed, error)
- **Progress Tracking**: Visual progress bars show task completion
- **Prompt System**: Send prompts to agents and view their responses

### User Interface
- **Native iOS Design**: Built with SwiftUI for a smooth, native experience
- **Dark Mode Support**: Seamless integration with iOS dark mode
- **Responsive Layout**: Optimized for both iPhone and iPad
- **Visual Indicators**: Color-coded status indicators and animations

## 🏗️ Architecture

### Data Models
```swift
Project
├── name: String
├── workingDirectory: String
├── createdDate: Date
└── agents: [Agent]

Agent
├── name: String
├── description: String
├── isRunning: Bool
├── status: AgentStatus
├── progress: Double
├── promptHistory: [(String, String)]
└── createdDate: Date
```

### Key Components
- **DataStore**: Singleton managing all app data and state
- **Views**: Modular SwiftUI views for each screen
- **Models**: Clean data structures for projects and agents

## 🔗 VibeTunnel Integration (Planned)

This app is designed to work seamlessly with `vibetunnel.sh`, which will provide:
- Secure connection to remote development environments
- Real-time agent communication and control
- File system access and code execution
- Persistent agent sessions

### Future Integration Points
1. **WebSocket Connection**: Real-time communication with vibetunnel server
2. **Authentication**: Secure login to access personal projects
3. **File Synchronization**: Browse and edit project files
4. **Terminal Access**: Execute commands in project directories
5. **Agent API**: Direct integration with AI coding assistants

## 📱 Requirements

- iOS 15.0 or later
- iPhone or iPad
- Internet connection (for vibetunnel integration)

## 🛠️ Development Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/vibeios.git
cd vibeios
```

2. Open in Xcode:
```bash
open vibeios.xcodeproj
```

3. Build and run on your device or simulator

## 🚧 Current Status

The app currently provides:
- ✅ Complete UI for project and agent management
- ✅ Local state management
- ✅ Mock data for testing
- ⏳ Pending: Backend integration with vibetunnel.sh
- ⏳ Pending: Persistent storage
- ⏳ Pending: Network communication layer

## 🎨 Screenshots

### Projects List
- Overview of all projects
- Running agent indicators
- Quick access to project details

### Agent Management
- Start/stop controls
- Progress monitoring
- Prompt interface

### Project Details
- Agent list
- Project statistics
- Create new agents

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

[License details to be added]

## 🔮 Roadmap

### Phase 1: Foundation (Current)
- ✅ Core UI implementation
- ✅ Local state management
- ✅ Mock functionality

### Phase 2: Integration
- [ ] VibeTunnel.sh connection
- [ ] Real agent communication
- [ ] Authentication system
- [ ] Data persistence

### Phase 3: Enhanced Features
- [ ] Code editor integration
- [ ] Terminal emulator
- [ ] Multi-agent coordination
- [ ] Voice commands
- [ ] Push notifications

### Phase 4: Advanced Capabilities
- [ ] Offline mode
- [ ] Agent marketplace
- [ ] Collaboration features
- [ ] Custom agent templates

## 📞 Support

For questions or support:
- Create an issue in the GitHub repository
- Contact the Vibe development team
- Check the documentation wiki

---

**VibeIOS** - Empowering developers to code from anywhere with AI assistance 🚀