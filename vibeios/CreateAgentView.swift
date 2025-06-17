import SwiftUI

struct CreateAgentView: View {
    let projectId: UUID
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var apiService = VibeTunnelAPIService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var command = "bash -l"
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var autoStartClaude = true
    @State private var useBypassPermissions = UserDefaults.standard.bool(forKey: "claude_bypass_permissions")
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Terminal Session")) {
                    TextField("Initial Command", text: $command)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.body, design: .monospaced))
                }
                
                Section(header: Text("Claude Code")) {
                    Toggle("Auto-start Claude Code", isOn: $autoStartClaude)
                    
                    if autoStartClaude {
                        Toggle("Use bypass permissions flag", isOn: $useBypassPermissions)
                            .onChange(of: useBypassPermissions) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "claude_bypass_permissions")
                            }
                        
                        Text("Will run: \(buildClaudeCommand())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontDesign(.monospaced)
                    }
                }
                
                Section(header: Text("Connection Status")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(apiService.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text("VibeTunnel API")
                                .font(.caption)
                                .foregroundColor(apiService.isConnected ? .green : .red)
                        }
                        
                        if !apiService.isConnected {
                            Text("Connect to VibeTunnel API in Settings to create terminal sessions")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section {
                    Button(action: createSession) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Spacer()
                            Text(isCreating ? "Creating..." : "Create Session")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(isCreating || !apiService.isConnected)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createSession()
                    }
                    .disabled(isCreating || !apiService.isConnected)
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func createSession() {
        guard let project = dataStore.projects.first(where: { $0.id == projectId }) else {
            errorMessage = "Project not found"
            return
        }
        
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                let sessionResponse = try await dataStore.createSession(for: project, command: command)
                
                // Give extra time for session to be fully ready
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // If auto-start Claude is enabled, send the Claude command
                if autoStartClaude {
                    let claudeCommand = buildClaudeCommand() + "\n"
                    
                    // Send the Claude command to the newly created session
                    _ = try await apiService.sendInput(to: sessionResponse.id, text: claudeCommand)
                }
                
                // Ensure sessions are refreshed
                await dataStore.refreshSessionsFromAPI()
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isCreating = false
                }
            }
        }
    }
    
    private func buildClaudeCommand() -> String {
        var claudeCommand = "claude"
        
        if useBypassPermissions {
            claudeCommand += " --dangerously-skip-permissions"
        }
        
        return claudeCommand
    }
}

#Preview {
    CreateAgentView(projectId: UUID())
}