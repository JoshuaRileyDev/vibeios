import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var apiService = VibeTunnelAPIService.shared
    @State private var showingCreateAgent = false
    @State private var sessions: [Session] = []
    @State private var isRefreshing = false
    @State private var refreshTimer: Timer?
    
    private var currentProject: Project? {
        dataStore.projects.first { $0.id == project.id }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if let currentProject = currentProject {
                ScrollView {
                    VStack(spacing: 20) {
                        // Project Stats Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                                Text("Project Overview")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                StatsRowView(
                                    icon: "location.fill",
                                    label: "Working Directory",
                                    value: currentProject.workingDirectory,
                                    color: .orange
                                )
                                StatsRowView(
                                    icon: "cpu.fill",
                                    label: "Total Sessions",
                                    value: "\(sessions.count)",
                                    color: .blue
                                )
                                StatsRowView(
                                    icon: "play.circle.fill",
                                    label: "Running Sessions",
                                    value: "\(sessions.filter { $0.status.lowercased() == "running" }.count)",
                                    color: .green
                                )
                                StatsRowView(
                                    icon: "calendar",
                                    label: "Created",
                                    value: currentProject.createdAt.formatted(date: .abbreviated, time: .shortened),
                                    color: .purple
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        
                        // Sessions Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.purple)
                                Text("Terminal Sessions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            if sessions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "terminal")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("No sessions created yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("Tap the + button to create your first session")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                                )
                                .padding(.horizontal, 16)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                                        NavigationLink(destination: SessionDetailView(projectId: currentProject.id, session: session, agentNumber: index + 1)) {
                                            SessionRowView(session: session, agentNumber: index + 1)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Refresh") {
                    refreshSessions()
                }
                .disabled(isRefreshing)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCreateAgent = true
                }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateAgent) {
            CreateAgentView(projectId: project.id)
        }
        .onAppear {
            refreshSessions()
            startPeriodicRefresh()
        }
        .onDisappear {
            stopPeriodicRefresh()
        }
    }
    
    private func refreshSessions() {
        guard let currentProject = currentProject else { return }
        
        isRefreshing = true
        
        Task {
            // Refresh sessions from API
            await dataStore.refreshSessionsFromAPI()
            
            await MainActor.run {
                self.sessions = dataStore.getSessionsForProject(currentProject)
                self.isRefreshing = false
            }
        }
    }
    
    private func startPeriodicRefresh() {
        // Refresh every 10 seconds when there are active sessions
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            if !sessions.isEmpty && apiService.isConnected {
                refreshSessions()
            }
        }
    }
    
    private func stopPeriodicRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
}

struct SessionRowView: View {
    let session: Session
    let agentNumber: Int
    
    var statusColor: Color {
        switch session.status.lowercased() {
        case "running":
            return .green
        case "exited", "stopped":
            return .red
        default:
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Agent Number Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: session.status.lowercased() == "running" ? 
                            [Color.green.opacity(0.8), Color.mint.opacity(0.8)] :
                            [Color.gray.opacity(0.6), Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                
                Text("\(agentNumber)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Agent \(agentNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(session.status.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(session.command)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if let pid = session.pid {
                        HStack(spacing: 4) {
                            Image(systemName: "number")
                                .font(.system(size: 8))
                                .foregroundColor(.blue)
                            Text("PID: \(pid)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    Text(session.id.prefix(8))
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        )
    }
}

struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationView {
        ProjectDetailView(project: Project(name: "Sample Project", workingDirectory: "/Users/sample/project"))
    }
}