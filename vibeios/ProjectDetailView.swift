import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @StateObject private var dataStore = DataStore.shared
    @State private var showingCreateAgent = false
    
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
                                    label: "Total Agents",
                                    value: "\(currentProject.agents.count)",
                                    color: .blue
                                )
                                StatsRowView(
                                    icon: "play.circle.fill",
                                    label: "Running Agents",
                                    value: "\(currentProject.runningAgentsCount)",
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
                        
                        // Agents Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "brain.head.profile.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.purple)
                                Text("Agents")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            if currentProject.agents.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("No agents created yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("Tap the + button to create your first agent")
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
                                    ForEach(currentProject.agents) { agent in
                                        NavigationLink(destination: AgentDetailView(projectId: currentProject.id, agent: agent)) {
                                            AgentRowView(agent: agent)
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
    }
    
    private func deleteAgents(offsets: IndexSet, from project: Project) {
        withAnimation {
            for index in offsets {
                let agent = project.agents[index]
                dataStore.deleteAgent(from: project.id, agentId: agent.id)
            }
        }
    }
}

struct AgentRowView: View {
    let agent: Agent
    
    var body: some View {
        HStack(spacing: 16) {
            // Agent Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: agent.isRunning ? 
                            [Color.green.opacity(0.8), Color.mint.opacity(0.8)] :
                            [Color.gray.opacity(0.6), Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(agent.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if agent.isRunning {
                        HStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 16, height: 16)
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .scaleEffect(1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                        value: agent.isRunning
                                    )
                            }
                            Text("Running")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        Text("Idle")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Text(agent.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if agent.isRunning && agent.progress > 0 {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 8))
                                .foregroundColor(.blue)
                            Text("Progress: \(Int(agent.progress * 100))%")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        
                        ProgressView(value: agent.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(y: 0.8)
                    }
                }
                
                if let lastPrompt = agent.lastPrompt {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.purple)
                        Text(lastPrompt)
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                            .lineLimit(1)
                    }
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