import SwiftUI

struct SessionDetailView: View {
    let projectId: UUID
    let session: Session
    let agentNumber: Int
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var apiService = VibeTunnelAPIService.shared
    @State private var terminalOutput = ""
    @State private var commandInput = ""
    @State private var isLoadingOutput = false
    @State private var errorMessage: String?
    @State private var isClaudeMode = false
    @State private var showingClaudeSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Agent Info Header
            agentInfoHeader
            
            // Terminal Output Section
            terminalOutputSection
            
            // Command Input Section
            if session.status.lowercased() == "running" {
                commandInputSection
            }
        }
        .navigationTitle("Agent \(agentNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showingClaudeSheet = true
                    }) {
                        Image(systemName: "brain")
                            .foregroundColor(.purple)
                    }
                    
                    Button("Refresh") {
                        loadTerminalOutput()
                    }
                    .disabled(isLoadingOutput)
                    
                    if session.status.lowercased() == "running" {
                        Button("Kill") {
                            killSession()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadTerminalOutput()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showingClaudeSheet) {
            ClaudeCodeLaunchView(session: session) { command in
                showingClaudeSheet = false
                sendCommandDirectly(command)
            }
        }
    }
    
    private var agentInfoHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Status indicator
                Circle()
                    .fill(session.status.lowercased() == "running" ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(session.status.uppercased())
                    .font(.headline)
                    .foregroundColor(session.status.lowercased() == "running" ? .green : .red)
                
                Spacer()
                
                Text("Session: \(session.id.prefix(8))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "terminal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.command)
                        .font(.body)
                        .fontDesign(.monospaced)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.workingDir)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let pid = session.pid {
                    HStack {
                        Image(systemName: "number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("PID: \(pid)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var terminalOutputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Terminal Output")
                    .font(.headline)
                    .padding(.horizontal)
                
                Spacer()
                
                if isLoadingOutput {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.horizontal)
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let errorMessage = errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 30))
                                .foregroundColor(.orange)
                            
                            Text("Error Loading Output")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else if terminalOutput.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "terminal")
                                .font(.system(size: 30))
                                .foregroundColor(.secondary)
                            
                            Text("No terminal output yet")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button("Load Output") {
                                loadTerminalOutput()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else {
                        // Limit output to prevent UI freezing
                        let limitedOutput = String(terminalOutput.suffix(5000))
                        
                        let cleanedOutput = cleanTerminalOutput(limitedOutput)
                        
                        if detectClaudeCodeOutput(in: cleanedOutput) {
                            // Claude Code formatted output
                            ClaudeCodeOutputView(output: cleanedOutput)
                        } else {
                            // Enhanced terminal output display
                            EnhancedTerminalOutputView(output: cleanedOutput)
                        }
                        
                        if terminalOutput.count > 5000 {
                            Text("Showing last 5000 characters of \(terminalOutput.count) total")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private var commandInputSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            // Voice Input Section
            VoiceInputView { voiceCommand in
                sendVoiceCommand(voiceCommand)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Enter command...", text: $commandInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        sendCommand()
                    }
                
                Button("Send") {
                    sendCommand()
                }
                .disabled(commandInput.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private func loadTerminalOutput() {
        isLoadingOutput = true
        errorMessage = nil
        
        Task {
            do {
                let output = try await apiService.getSessionSnapshot(sessionId: session.id)
                await MainActor.run {
                    self.terminalOutput = output
                    self.isLoadingOutput = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingOutput = false
                }
            }
        }
    }
    
    private func sendCommand() {
        guard !commandInput.isEmpty else { return }
        
        let command = commandInput + "\n"
        commandInput = ""
        
        Task {
            do {
                _ = try await apiService.sendInput(to: session.id, text: command)
                
                // Refresh sessions list and output after command
                await dataStore.refreshSessionsFromAPI()
                
                // Wait for command to process then refresh output
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                loadTerminalOutput()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to send command: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func sendVoiceCommand(_ voiceCommand: String) {
        guard !voiceCommand.isEmpty else { return }
        
        let command = voiceCommand + "\n"
        
        Task {
            do {
                _ = try await apiService.sendInput(to: session.id, text: command)
                
                // Refresh sessions list and output after command
                await dataStore.refreshSessionsFromAPI()
                
                // Wait for command to process then refresh output
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                loadTerminalOutput()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to send voice command: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func killSession() {
        Task {
            do {
                _ = try await apiService.killSession(sessionId: session.id)
                
                // Refresh the parent view
                await MainActor.run {
                    dataStore.loadSessionsFromAPI()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to kill session: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func sendCommandDirectly(_ command: String) {
        // For Claude commands, add extra refresh time since they take longer
        let isClaudeCommand = command.contains("claude")
        
        Task {
            do {
                _ = try await apiService.sendInput(to: session.id, text: command + "\n")
                
                // Refresh sessions list immediately
                await dataStore.refreshSessionsFromAPI()
                
                // Wait longer for Claude commands to process
                let waitTime: UInt64 = isClaudeCommand ? 3_000_000_000 : 1_500_000_000 // 3s for Claude, 1.5s for others
                try await Task.sleep(nanoseconds: waitTime)
                
                loadTerminalOutput()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to send command: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func detectClaudeCodeOutput(in text: String) -> Bool {
        // Detect Claude Code output patterns
        let claudePatterns = [
            "Claude Code",
            "Tool Use:",
            "Human:",
            "Assistant:",
            "```",
            "━━━",
            "│",
            "└",
            "├"
        ]
        
        return claudePatterns.contains { text.contains($0) }
    }
    
    private func cleanTerminalOutput(_ text: String) -> String {
        // Remove ANSI escape sequences
        let ansiPattern = #"\u001b\[[0-9;]*[a-zA-Z]"#
        var cleaned = text
        
        do {
            let regex = try NSRegularExpression(pattern: ansiPattern, options: [])
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                options: [],
                range: NSRange(location: 0, length: cleaned.utf16.count),
                withTemplate: ""
            )
        } catch {
            // If regex fails, continue with original text
        }
        
        // Normalize Unicode characters
        cleaned = cleaned.precomposedStringWithCanonicalMapping
        
        // Replace common Unicode characters with ASCII equivalents
        let unicodeReplacements = [
            "…": "...",
            "·": "·",
            "↑": "^"
        ]
        
        for (unicode, ascii) in unicodeReplacements {
            cleaned = cleaned.replacingOccurrences(of: unicode, with: ascii)
        }
        
        return cleaned
    }
}

// MARK: - Claude Code Output View

struct ClaudeCodeOutputView: View {
    let output: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(output.components(separatedBy: "\n").indices, id: \.self) { index in
                    let line = output.components(separatedBy: "\n")[index]
                    formatLine(line)
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func formatLine(_ line: String) -> some View {
        if line.contains("Human:") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.cyan)
                .fontWeight(.bold)
        } else if line.contains("Assistant:") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.green)
                .fontWeight(.bold)
        } else if line.contains("Tool Use:") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.orange)
                .fontWeight(.semibold)
        } else if line.starts(with: "```") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.purple)
        } else if line.contains("━") || line.contains("│") || line.contains("└") || line.contains("├") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
        } else if line.contains("Error") || line.contains("error") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.red)
        } else if line.contains("Success") || line.contains("✓") {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.green)
        } else {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Claude Code Launch View

struct ClaudeCodeLaunchView: View {
    let session: Session
    let onLaunch: (String) -> Void
    @State private var prompt = ""
    @State private var useBypassPermissions = UserDefaults.standard.bool(forKey: "claude_bypass_permissions")
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Launch Claude Code")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your prompt for Claude Code or use quick actions")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Quick Actions
                VStack(spacing: 12) {
                    quickActionButton(
                        title: "Open Claude Code",
                        icon: "brain",
                        command: buildClaudeCommand("")
                    )
                    
                    quickActionButton(
                        title: "Analyze Current Directory",
                        icon: "doc.text.magnifyingglass",
                        command: buildClaudeCommand("analyze the current directory structure and explain what this project does")
                    )
                    
                    quickActionButton(
                        title: "Find TODOs",
                        icon: "checklist",
                        command: buildClaudeCommand("find all TODO comments in the codebase")
                    )
                    
                    quickActionButton(
                        title: "Check for Issues",
                        icon: "exclamationmark.triangle",
                        command: buildClaudeCommand("check for potential issues or bugs in the current project")
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
                // Custom Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Prompt")
                        .font(.headline)
                    
                    TextEditor(text: $prompt)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(minHeight: 100)
                    
                    Button(action: {
                        let command = buildClaudeCommand(prompt)
                        onLaunch(command)
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send to Claude")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(prompt.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private func quickActionButton(title: String, icon: String, command: String) -> some View {
        Button(action: {
            onLaunch(command)
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func buildClaudeCommand(_ prompt: String) -> String {
        var command = "claude"
        
        if useBypassPermissions {
            command += " --dangerously-skip-permissions"
        }
        
        if !prompt.isEmpty {
            // Escape the prompt for shell
            let escapedPrompt = prompt
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "$", with: "\\$")
                .replacingOccurrences(of: "`", with: "\\`")
            command += " \"\(escapedPrompt)\""
        }
        
        return command
    }
}

// MARK: - Enhanced Terminal Output View

struct EnhancedTerminalOutputView: View {
    let output: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                if output.isEmpty {
                    Text("No output available")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    let lines = output.components(separatedBy: .newlines)
                    
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                // Line number
                                Text("\(index + 1)")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 30, alignment: .trailing)
                                
                                // Line content
                                Text(line)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(colorForLine(line))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 1)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .cornerRadius(8)
    }
    
    private func colorForLine(_ line: String) -> Color {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Error patterns
        if trimmed.contains("error") || trimmed.contains("Error") || trimmed.contains("ERROR") {
            return .red
        }
        
        // Warning patterns
        if trimmed.contains("warning") || trimmed.contains("Warning") || trimmed.contains("WARN") {
            return .orange
        }
        
        // Success patterns
        if trimmed.contains("success") || trimmed.contains("Success") || trimmed.contains("✓") || trimmed.contains("done") {
            return .green
        }
        
        // Info patterns
        if trimmed.contains("info") || trimmed.contains("Info") || trimmed.starts(with: ">") {
            return .cyan
        }
        
        // Command patterns
        if trimmed.starts(with: "$") || trimmed.starts(with: "#") {
            return .yellow
        }
        
        // Default terminal green
        return .green
    }
}

#Preview {
    NavigationView {
        SessionDetailView(
            projectId: UUID(),
            session: Session(
                id: "test-session",
                command: "bash -l",
                workingDir: "/Users/test",
                status: "running",
                exitCode: nil,
                startedAt: "2024-01-01T12:00:00Z",
                lastModified: "2024-01-01T12:05:00Z",
                pid: 12345
            ),
            agentNumber: 1
        )
    }
}