import SwiftUI

struct AgentDetailView: View {
    let projectId: UUID
    let agent: Agent
    @StateObject private var dataStore = DataStore.shared
    @State private var promptText = ""
    @State private var showingPromptSheet = false
    
    private var currentAgent: Agent? {
        dataStore.projects
            .first { $0.id == projectId }?
            .agents
            .first { $0.id == agent.id }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let currentAgent = currentAgent {
                        AgentStatusCard(agent: currentAgent)
                        
                        AgentControlsCard(
                            agent: currentAgent,
                            onStart: { startAgent() },
                            onStop: { stopAgent() },
                            onPrompt: { showingPromptSheet = true }
                        )
                        
                        if let lastPrompt = currentAgent.lastPrompt {
                            PromptHistoryCard(lastPrompt: lastPrompt, lastResponse: currentAgent.lastResponse)
                        }
                        
                        AgentInfoCard(agent: currentAgent)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(agent.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingPromptSheet) {
            PromptInputView(
                promptText: $promptText,
                onSend: { sendPrompt() },
                onCancel: { showingPromptSheet = false }
            )
        }
    }
    
    private func startAgent() {
        dataStore.startAgent(in: projectId, agentId: agent.id)
        simulateProgress()
    }
    
    private func stopAgent() {
        dataStore.stopAgent(in: projectId, agentId: agent.id)
    }
    
    private func sendPrompt() {
        guard !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if let currentAgent = currentAgent {
            var updatedAgent = currentAgent
            updatedAgent.lastPrompt = promptText
            updatedAgent.lastResponse = "Processing your request..."
            dataStore.updateAgent(in: projectId, agent: updatedAgent)
            
            simulateResponse()
        }
        
        promptText = ""
        showingPromptSheet = false
    }
    
    private func simulateProgress() {
        guard let currentAgent = currentAgent, currentAgent.isRunning else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            guard let agent = self.currentAgent, agent.isRunning else {
                timer.invalidate()
                return
            }
            
            var updatedAgent = agent
            updatedAgent.progress = min(updatedAgent.progress + 0.1, 1.0)
            dataStore.updateAgent(in: projectId, agent: updatedAgent)
            
            if updatedAgent.progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
    
    private func simulateResponse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let currentAgent = currentAgent {
                var updatedAgent = currentAgent
                updatedAgent.lastResponse = "Task completed successfully. Ready for next instruction."
                dataStore.updateAgent(in: projectId, agent: updatedAgent)
            }
        }
    }
}

struct AgentStatusCard: View {
    let agent: Agent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                Text("Status")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                StatusBadge(isRunning: agent.isRunning)
            }
            
            if agent.isRunning {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "speedometer")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("Progress")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(agent.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, CGFloat(agent.progress) * 200), height: 8)
                            .animation(.easeInOut(duration: 0.3), value: agent.progress)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct AgentControlsCard: View {
    let agent: Agent
    let onStart: () -> Void
    let onStop: () -> Void
    let onPrompt: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.purple)
                Text("Controls")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                if agent.isRunning {
                    Button(action: onStop) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Stop")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: onStart) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Start")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                Button(action: onPrompt) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Prompt")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct PromptHistoryCard: View {
    let lastPrompt: String
    let lastResponse: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest Interaction")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Prompt:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(lastPrompt)
                    .font(.body)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                if let response = lastResponse {
                    Text("Response:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(response)
                        .font(.body)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AgentInfoCard: View {
    let agent: Agent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agent Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Name", value: agent.name)
                InfoRow(label: "Description", value: agent.description)
                InfoRow(label: "Created", value: agent.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusBadge: View {
    let isRunning: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(isRunning ? "Running" : "Idle")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isRunning ? .green : .gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isRunning ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

struct PromptInputView: View {
    @Binding var promptText: String
    let onSend: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Send a prompt to your agent")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $promptText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(minHeight: 120)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send", action: onSend)
                        .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AgentDetailView(
            projectId: UUID(),
            agent: Agent(name: "Sample Agent", description: "A sample agent for testing")
        )
    }
}