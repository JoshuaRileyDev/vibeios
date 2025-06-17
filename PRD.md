# VibeIOS - Product Requirements Document (PRD)

**Version:** 1.0  
**Last Updated:** June 17, 2025  
**Document Owner:** Joshua Riley  
**Project Status:** Active Development  

---

## 📋 Table of Contents

1. [Product Overview](#product-overview)
2. [Current Architecture](#current-architecture)
3. [Implemented Features](#implemented-features)
4. [Technical Specifications](#technical-specifications)
5. [User Stories & Use Cases](#user-stories--use-cases)
6. [API Integration](#api-integration)
7. [Data Models](#data-models)
8. [User Interface Components](#user-interface-components)
9. [Future Roadmap](#future-roadmap)
10. [Team Collaboration Guidelines](#team-collaboration-guidelines)

---

## 🎯 Product Overview

### **Product Vision**
VibeIOS is a mobile companion app for developers using VibeTunnel server environments, enabling remote terminal session management, AI tool integration, and voice-controlled development workflows directly from iOS devices.

### **Target Users**
- **Primary:** Software developers using remote development environments
- **Secondary:** DevOps engineers managing multiple server instances
- **Tertiary:** Students learning development in cloud environments

### **Core Value Proposition**
- **Remote Control:** Manage terminal sessions from anywhere
- **AI Integration:** Seamless Claude Code integration with real-time monitoring
- **Voice Interface:** Hands-free command execution for accessibility
- **Project Organization:** Structured workflow management by project context

---

## 🏗️ Current Architecture

### **Technology Stack**
- **Platform:** iOS 15.0+
- **Framework:** SwiftUI with Combine
- **Architecture:** MVVM with Reactive Programming
- **Networking:** URLSession with async/await
- **Storage:** UserDefaults for local persistence
- **Voice:** iOS Speech Framework

### **Key Design Patterns**
- **Singleton Pattern:** DataStore and API service management
- **Observer Pattern:** @Published properties for reactive UI updates
- **Repository Pattern:** API service abstraction layer
- **Command Pattern:** Voice input to terminal command translation

### **Project Structure**
```
VibeIOS/
├── App Layer
│   ├── vibeiosApp.swift           # App entry point
│   └── ContentView.swift          # Root navigation
├── Data Layer
│   ├── Models.swift               # Core data models
│   ├── DataStore.swift            # State management
│   └── VibeTunnelAPI.swift        # API service & parsing
├── UI Layer
│   ├── ProjectsListView.swift     # Main project overview
│   ├── ProjectDetailView.swift    # Individual project management
│   ├── CreateProjectView.swift    # Project creation form
│   ├── CreateAgentView.swift      # Session creation with AI
│   ├── SessionDetailView.swift    # Terminal interface
│   └── SettingsView.swift         # Configuration panel
└── Voice Layer
    ├── VoiceInputView.swift       # Speech UI component
    └── SpeechRecognitionManager.swift # Voice processing
```

---

## ✅ Implemented Features

### **1. Project Management System**

#### **1.1 Project Creation & Storage**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Users can create named projects with working directory associations
- ✅ **Storage:** Local persistence using UserDefaults with JSON encoding
- ✅ **Validation:** Directory path validation and duplicate name prevention

**Implementation Details:**
- Project model with UUID, name, directory, and creation date
- Automatic persistence on creation/deletion
- Clean empty state for new users

#### **1.2 Project List Interface**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Card-based layout showing all projects with session counts
- ✅ **Real-time Updates:** Live session count badges with 5-second refresh intervals
- ✅ **Navigation:** Tap-to-navigate to project details

**UI Components:**
- Project cards with visual status indicators
- Session count badges with color coding
- Pull-to-refresh functionality
- Settings access via toolbar

### **2. Terminal Session Management**

#### **2.1 Session Creation**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Create terminal sessions in project working directories
- ✅ **Customization:** Configurable shell commands and terminal types
- ✅ **Auto-start Integration:** Optional Claude Code auto-launch

**Features:**
- Command customization (bash, zsh, etc.)
- Working directory inheritance from projects
- Terminal type configuration (xterm-256color)
- Session validation and error handling

#### **2.2 Session Monitoring**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Real-time session status tracking and display
- ✅ **State Detection:** Running, exited, stopped status monitoring
- ✅ **Live Updates:** Automatic refresh every 5 seconds

**Implementation:**
- Session filtering by project context
- Status color coding (green=running, red=stopped)
- Real-time session count updates
- Automatic cleanup of terminated sessions

#### **2.3 Session Interaction**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Full terminal I/O with command execution
- ✅ **Output Display:** Syntax-highlighted terminal output
- ✅ **Command Input:** Text and voice input support

**Capabilities:**
- Real-time terminal output viewing
- Command execution with newline handling
- Output scrolling and line numbering
- Session termination (kill command)

### **3. AI Integration System**

#### **3.1 Claude Code Auto-start**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Automatic Claude Code launch when creating sessions
- ✅ **Configuration:** Toggle for auto-start with bypass permissions
- ✅ **Command Building:** Dynamic command construction with flags

**Features:**
- Auto-start toggle in session creation
- `--dangerously-skip-permissions` flag support
- Command preview before execution
- Persistent settings via UserDefaults

#### **3.2 AI Session State Detection**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Advanced terminal output parsing for AI activity detection
- ✅ **Real-time Monitoring:** Live countdown timers and token tracking
- ✅ **Pattern Recognition:** Multiple format support for Claude output

**Parsing Capabilities:**
- JSON timestamp format parsing: `[2637.05856875,"o","..."]`
- Traditional format parsing: `"✽ Documenting… (157s · ↑ 416 tokens · esc to interrupt)"`
- ANSI escape sequence cleaning
- Unicode character normalization
- Token count extraction and estimation

#### **3.3 AI Status Display**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Visual indicators for AI activity states
- ✅ **Information Display:** Running time, token counts, idle states
- ✅ **Color Coding:** Purple for AI running, green for terminal running

**UI Elements:**
- AI running badges with timer displays
- Token consumption indicators
- Visual state transitions (idle → running → completed)
- Session state refresh every 5 seconds

#### **3.4 Claude Code Quick Actions**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Pre-built Claude Code command templates
- ✅ **Custom Prompts:** Text editor for custom AI instructions
- ✅ **Command Escaping:** Safe shell command construction

**Quick Actions:**
- "Open Claude Code" - Basic launch
- "Analyze Current Directory" - Project analysis
- "Find TODOs" - Code comment scanning
- "Check for Issues" - Bug detection
- Custom prompt input with shell escaping

### **4. Voice Input System**

#### **4.1 Speech Recognition**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Real-time speech-to-text conversion for commands
- ✅ **Integration:** iOS Speech Framework with permission handling
- ✅ **Error Handling:** Comprehensive error states and user feedback

**Capabilities:**
- Real-time speech recognition with visual feedback
- Automatic permission request handling
- Error recovery for recognition failures
- Voice activity indicators

#### **4.2 Voice Command Execution**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Convert voice input directly to terminal commands
- ✅ **Seamless Integration:** Same execution path as text input
- ✅ **Feedback:** Visual confirmation of voice commands

**Features:**
- Voice-to-command conversion
- Automatic newline appending for execution
- Error handling for failed voice commands
- Integration with session detail view

### **5. Advanced Terminal Features**

#### **5.1 Output Processing**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Sophisticated terminal output cleaning and formatting
- ✅ **ANSI Support:** Complete escape sequence removal
- ✅ **Format Detection:** Automatic Claude Code vs standard output detection

**Processing Features:**
- Multiple ANSI escape pattern removal
- JSON terminal data extraction
- Unicode character normalization
- Output truncation for performance (5000 chars)

#### **5.2 Enhanced Display**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Syntax-highlighted terminal output with special formatting
- ✅ **Color Coding:** Different colors for errors, warnings, success, commands
- ✅ **Line Numbers:** Optional line numbering for better readability

**Display Features:**
- Color-coded output by content type
- Horizontal scrolling support
- Line-by-line formatting
- Claude Code specific highlighting

### **6. Settings & Configuration**

#### **6.1 VibeTunnel API Configuration**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Complete API server configuration management
- ✅ **Authentication:** Basic auth support with credential storage
- ✅ **Connection Testing:** Real-time connectivity verification

**Settings:**
- Base URL configuration with validation
- Username/password storage in UserDefaults
- Connection status indicators
- Health check functionality

#### **6.2 Voice Settings**
- ✅ **Status:** Fully Implemented
- ✅ **Description:** Voice input configuration and permission management
- ✅ **Permission Handling:** Automatic permission requests and status display
- ✅ **Error Recovery:** Comprehensive error handling for voice failures

---

## 🔧 Technical Specifications

### **Performance Requirements**
- **Startup Time:** < 2 seconds cold start
- **API Response:** < 1 second for session operations
- **Voice Recognition:** < 500ms speech-to-text conversion
- **UI Refresh:** 5-second intervals for session state updates
- **Memory Usage:** < 50MB typical operation

### **Compatibility**
- **iOS Version:** 15.0 minimum, 17.0+ recommended
- **Devices:** iPhone and iPad (universal)
- **Orientations:** Portrait and landscape support
- **Accessibility:** VoiceOver and Dynamic Type support

### **Security**
- **Credentials:** Stored in UserDefaults (consider Keychain for production)
- **Network:** HTTPS preferred, HTTP fallback for development
- **Permissions:** Microphone access for voice input
- **Data:** No sensitive data stored locally beyond server credentials

---

## 👥 User Stories & Use Cases

### **Primary User Personas**

#### **Persona 1: Remote Developer**
- **Background:** Full-stack developer working from multiple locations
- **Goals:** Access development environments from mobile device
- **Pain Points:** Need quick access to terminal and AI tools while away from desk

#### **Persona 2: DevOps Engineer**
- **Background:** Manages multiple server environments and deployments
- **Goals:** Monitor and control sessions across different projects
- **Pain Points:** Needs real-time status updates and quick command execution

### **Core User Journeys**

#### **Journey 1: First-time Setup**
1. User downloads and opens VibeIOS
2. Navigates to Settings to configure VibeTunnel server
3. Enters server URL and authentication (if required)
4. Creates first project with working directory
5. Creates first terminal session with Claude auto-start
6. Grants microphone permission for voice input

#### **Journey 2: Daily Development Workflow**
1. User opens app to check session status
2. Sees running sessions with AI activity indicators
3. Taps into session detail to view AI progress (timer/tokens)
4. Uses voice input to execute quick commands
5. Launches Claude Code with quick action prompts
6. Monitors AI task completion through status updates

#### **Journey 3: Project Management**
1. User creates new project for different codebase
2. Associates project with specific server directory
3. Creates multiple sessions for different tasks
4. Monitors all sessions from project overview
5. Terminates completed sessions to free resources

---

## 🔌 API Integration

### **VibeTunnel API Endpoints**

#### **Session Management**
```http
GET    /api/sessions              # List all sessions
POST   /api/sessions              # Create new session
DELETE /api/sessions/{id}         # Kill session
DELETE /api/sessions/{id}/cleanup # Clean up session
GET    /api/sessions/{id}/snapshot # Get terminal output
POST   /api/sessions/{id}/input   # Send command input
```

#### **Server Operations**
```http
GET  /api/health                  # Health check
GET  /info                        # Server information
POST /api/cleanup-exited          # Clean all exited sessions
```

#### **File System**
```http
GET  /api/fs/browse               # Browse directories
```

#### **Ngrok Tunneling**
```http
POST /api/ngrok/start             # Start tunnel
POST /api/ngrok/stop              # Stop tunnel
GET  /api/ngrok/status            # Tunnel status
```

### **Request/Response Models**

#### **Session Creation Request**
```json
{
  "command": ["bash", "-l"],
  "workingDir": "/path/to/project",
  "term": "xterm-256color",
  "spawn_terminal": false
}
```

#### **API Response Format**
```json
{
  "success": true,
  "message": "Operation completed",
  "sessionId": "uuid-string",
  "data": { ... }
}
```

---

## 📊 Data Models

### **Core Models**

#### **Project Model**
```swift
struct Project: Identifiable, Codable {
    let id: UUID                    // Unique identifier
    var name: String               // Display name
    var workingDirectory: String   // Server path
    var createdAt: Date           // Creation timestamp
}
```

#### **Session Model**
```swift
struct Session: Codable, Identifiable {
    let id: String              // Server-assigned ID
    let command: String         // Execution command
    let workingDir: String      // Working directory
    let status: String          // running/exited/stopped
    let exitCode: Int?          // Exit code if terminated
    let startedAt: String       // ISO 8601 timestamp
    let lastModified: String    // ISO 8601 timestamp
    let pid: Int?              // Process ID
}
```

#### **SessionState Model**
```swift
struct SessionState {
    let isAIRunning: Bool       // AI activity status
    let runningSeconds: Int?    // Elapsed time
    let tokenCount: Int?        // Token consumption
    let isIdle: Bool           // Idle state
}
```

### **Data Flow Architecture**
```
UI Layer (Views)
    ↕ @Published bindings
DataStore (ObservableObject)
    ↕ async/await calls
VibeTunnelAPIService (Singleton)
    ↕ HTTP requests
VibeTunnel Server
```

---

## 🎨 User Interface Components

### **Navigation Structure**
```
ContentView (Root)
├── ProjectsListView (Main)
│   ├── SettingsView (Modal)
│   ├── CreateProjectView (Modal)
│   └── ProjectDetailView (Navigation)
│       ├── CreateAgentView (Modal)
│       └── SessionDetailView (Navigation)
│           ├── VoiceInputView (Embedded)
│           └── ClaudeCodeLaunchView (Modal)
```

### **Key UI Components**

#### **Project Cards**
- **Layout:** Card-based design with shadow and rounded corners
- **Content:** Project name, directory, session count badge
- **Interaction:** Tap to navigate, swipe for delete (future)
- **Status:** Color-coded session count badges

#### **Session Rows**
- **Layout:** List rows with agent numbering and status indicators
- **Content:** Agent number, command, directory, AI status
- **Status:** Visual indicators for running/idle/AI active states
- **Real-time:** Timer and token displays for AI sessions

#### **Terminal Interface**
- **Layout:** Full-screen terminal emulation
- **Features:** Scrollable output, command input bar, voice button
- **Formatting:** Syntax highlighting, line numbers, color coding
- **Controls:** Refresh, kill session, Claude Code launch

#### **Voice Input Component**
- **Visual:** Animated microphone button with activity indicator
- **Feedback:** Real-time speech recognition display
- **States:** Idle, listening, processing, error
- **Integration:** Seamless command execution flow

---

## 🛣️ Future Roadmap

### **Phase 1: Core Enhancements (Next 2-4 weeks)**

#### **P0 - Critical**
- [ ] **Keychain Integration** - Secure credential storage
- [ ] **Error Recovery** - Automatic reconnection and retry logic
- [ ] **Offline Mode** - Basic functionality when disconnected
- [ ] **Performance Optimization** - Reduce memory usage and improve startup

#### **P1 - High Priority**
- [ ] **Session Persistence** - Remember session states across app launches
- [ ] **Background Refresh** - Update session status when app is backgrounded
- [ ] **Push Notifications** - Alert for session completion or errors
- [ ] **Export/Import** - Project configuration backup and restore

### **Phase 2: Advanced Features (4-8 weeks)**

#### **P1 - High Priority**
- [ ] **File Browser** - Navigate server file system
- [ ] **Code Editor** - Basic file editing capabilities
- [ ] **Terminal Emulation** - Full terminal feature support
- [ ] **Session Templates** - Pre-configured session types

#### **P2 - Medium Priority**
- [ ] **Multi-server Support** - Connect to multiple VibeTunnel instances
- [ ] **Team Collaboration** - Share sessions and projects
- [ ] **Custom Commands** - Saved command shortcuts
- [ ] **Session Grouping** - Organize sessions by tags or categories

### **Phase 3: Enterprise Features (8-12 weeks)**

#### **P2 - Medium Priority**
- [ ] **SSO Integration** - Enterprise authentication support
- [ ] **Audit Logging** - Track all user actions and commands
- [ ] **Admin Dashboard** - Server management interface
- [ ] **API Rate Limiting** - Request throttling and quotas

#### **P3 - Low Priority**
- [ ] **Plugin System** - Third-party integrations
- [ ] **Custom Themes** - UI customization options
- [ ] **Advanced Analytics** - Usage tracking and insights
- [ ] **Accessibility Enhancements** - VoiceOver and Switch Control

### **Platform Expansions (12+ weeks)**
- [ ] **iPad Optimization** - Split-view and multi-window support
- [ ] **macOS Catalyst** - Native macOS version
- [ ] **Apple Watch** - Quick status monitoring
- [ ] **Shortcuts Integration** - Siri command support

---

## 🤝 Team Collaboration Guidelines

### **Development Workflow**

#### **Git Branch Strategy**
```
main                    # Production-ready code
├── develop            # Integration branch
├── feature/[name]     # New features
├── bugfix/[name]      # Bug fixes
└── hotfix/[name]      # Critical production fixes
```

#### **Commit Standards**
- **Format:** `[type]: [description]` (e.g., `feat: add voice input support`)
- **Types:** feat, fix, docs, style, refactor, test, chore
- **Description:** Imperative mood, max 50 characters
- **Body:** Detailed explanation when needed

#### **Code Review Process**
1. **Feature Branch:** Create from `develop`
2. **Implementation:** Follow coding standards and add tests
3. **Pull Request:** Submit with description and testing notes
4. **Review:** Minimum 1 reviewer, address all feedback
5. **Merge:** Squash commits and merge to `develop`
6. **Release:** Merge `develop` to `main` for releases

### **Coding Standards**

#### **Swift Style Guide**
- **Naming:** Use descriptive names for variables and functions
- **Comments:** Document public APIs and complex algorithms
- **Organization:** Use MARK comments for code sections
- **Architecture:** Follow MVVM pattern with dependency injection

#### **SwiftUI Best Practices**
- **State Management:** Use @Published and @StateObject appropriately
- **View Composition:** Break down complex views into smaller components
- **Performance:** Avoid unnecessary view rebuilds
- **Accessibility:** Include accessibility labels and hints

#### **Testing Strategy**
- **Unit Tests:** Test business logic and data models
- **Integration Tests:** Test API interactions
- **UI Tests:** Test critical user flows
- **Coverage:** Maintain >80% code coverage for core features

### **Feature Development Process**

#### **Before Starting Development**
1. **Review PRD:** Understand requirements and acceptance criteria
2. **Update PRD:** Add detailed specifications for new features
3. **Create Issues:** Break down features into manageable tasks
4. **Design Review:** Discuss UI/UX changes with team

#### **During Development**
1. **Regular Updates:** Push progress frequently to feature branch
2. **Documentation:** Update code comments and README as needed
3. **Testing:** Write tests alongside implementation
4. **Communication:** Share blockers and questions in team chat

#### **Before Merging**
1. **Self Review:** Check code quality and test coverage
2. **Manual Testing:** Verify functionality on device
3. **Documentation:** Update PRD with implementation details
4. **Performance:** Profile for memory leaks and performance issues

### **Communication Channels**

#### **Recommended Tools**
- **Project Management:** GitHub Issues/Projects or Jira
- **Code Review:** GitHub Pull Requests
- **Team Chat:** Slack, Discord, or Microsoft Teams
- **Documentation:** This PRD + inline code documentation

#### **Meeting Cadence**
- **Daily Standups:** Progress updates and blocker discussion
- **Weekly Planning:** Feature prioritization and sprint planning
- **Bi-weekly Reviews:** Code quality and architecture reviews
- **Monthly Retrospectives:** Process improvement discussions

---

## 📈 Success Metrics

### **Development Metrics**
- **Code Quality:** Maintain >90% passing tests
- **Performance:** Keep app memory usage <50MB
- **Reliability:** <1% crash rate in production
- **Coverage:** >80% code coverage for core features

### **User Experience Metrics**
- **Startup Time:** <2 seconds cold start
- **API Response:** <1 second for session operations
- **Voice Accuracy:** >95% speech recognition accuracy
- **Session Success:** >99% successful session creation

### **Feature Adoption**
- **Voice Input:** Track usage percentage of voice vs text commands
- **AI Integration:** Monitor Claude Code launch frequency
- **Project Management:** Track average projects per user
- **Session Management:** Monitor average concurrent sessions

---

## 📝 Documentation Maintenance

### **PRD Updates**
- **Weekly Reviews:** Update implementation status and add new requirements
- **Feature Completion:** Mark features as complete with implementation notes
- **New Features:** Add detailed specifications before development begins
- **Architecture Changes:** Document significant technical decisions

### **Version History**
- **v1.0 (June 17, 2025):** Initial PRD creation with current feature documentation
- **Future versions:** Track major feature additions and architectural changes

---

## 🎯 Conclusion

This PRD serves as the single source of truth for VibeIOS development, documenting all implemented features and providing a roadmap for future development. The app has achieved a solid foundation with comprehensive terminal session management, AI integration, and voice input capabilities.

**Current State:** Production-ready MVP with core functionality complete  
**Next Priorities:** Security enhancements, performance optimization, and advanced features  
**Team Ready:** Full documentation and development guidelines in place  

For questions or updates to this PRD, please contact the development team or create an issue in the GitHub repository.

---

*Last Updated: June 17, 2025 by Joshua Riley*