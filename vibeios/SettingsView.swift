import SwiftUI

struct SettingsView: View {
    @StateObject private var apiService = VibeTunnelAPIService.shared
    @State private var tempBaseURL: String = ""
    @State private var tempUsername: String = ""
    @State private var tempPassword: String = ""
    @State private var showingConnectionTest = false
    @State private var connectionTestResult: String = ""
    @State private var isTestingConnection = false
    @State private var useBypassPermissions = UserDefaults.standard.bool(forKey: "claude_bypass_permissions")
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Base URL")
                            .font(.headline)
                        TextField("http://localhost:8080", text: $tempBaseURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
                
                Section(header: Text("Authentication (Optional)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                        TextField("Username", text: $tempUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Password", text: $tempPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Connection Status")) {
                    HStack {
                        Circle()
                            .fill(apiService.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(apiService.isConnected ? "Connected" : "Disconnected")
                            .foregroundColor(apiService.isConnected ? .green : .red)
                        Spacer()
                        Button("Test Connection") {
                            testConnection()
                        }
                        .disabled(isTestingConnection)
                    }
                    
                    if showingConnectionTest {
                        Text(connectionTestResult)
                            .font(.caption)
                            .foregroundColor(connectionTestResult.contains("Success") ? .green : .red)
                    }
                }
                
                Section(header: Text("Claude Code CLI")) {
                    Toggle("Use Dangerous Bypass Permissions", isOn: $useBypassPermissions)
                        .onChange(of: useBypassPermissions) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "claude_bypass_permissions")
                        }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Enables --dangerously-bypass-permissions flag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button("Save Settings") {
                        saveSettings()
                    }
                    .disabled(tempBaseURL.isEmpty)
                    
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    saveSettings()
                    dismiss()
                }
            )
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func loadCurrentSettings() {
        tempBaseURL = apiService.baseURL
        tempUsername = apiService.username
        tempPassword = apiService.password
    }
    
    private func saveSettings() {
        apiService.updateBaseURL(tempBaseURL)
        apiService.updateCredentials(username: tempUsername, password: tempPassword)
    }
    
    private func resetToDefaults() {
        tempBaseURL = "http://localhost:8080"
        tempUsername = ""
        tempPassword = ""
        apiService.updateBaseURL(tempBaseURL)
        apiService.updateCredentials(username: tempUsername, password: tempPassword)
    }
    
    private func testConnection() {
        isTestingConnection = true
        showingConnectionTest = true
        
        Task {
            do {
                // Temporarily update API service with current settings
                let originalURL = apiService.baseURL
                let originalUsername = apiService.username
                let originalPassword = apiService.password
                
                apiService.updateBaseURL(tempBaseURL)
                apiService.updateCredentials(username: tempUsername, password: tempPassword)
                
                let healthResponse = try await apiService.healthCheck()
                
                await MainActor.run {
                    connectionTestResult = healthResponse.success ? "Success: Connected to VibeTunnel API" : "Error: \(healthResponse.message)"
                    isTestingConnection = false
                }
                
            } catch {
                await MainActor.run {
                    connectionTestResult = "Error: \(error.localizedDescription)"
                    isTestingConnection = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}