import SwiftUI

struct ProjectsListView: View {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var apiService = VibeTunnelAPIService.shared
    @State private var showingCreateProject = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(dataStore.projects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                let runningSessions = dataStore.getSessionsForProject(project) // Only running sessions now
                                ProjectRowView(
                                    project: project, 
                                    runningAgents: runningSessions.count,
                                    totalAgents: runningSessions.count // Same since we only show running
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 16)
                    .refreshable {
                        await dataStore.refreshSessionsFromAPI()
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        // Connection status indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(apiService.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text("VibeTunnel")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(apiService.isConnected ? .green : .red)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateProject = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.blue, Color.purple],
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
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                Task {
                    await dataStore.refreshSessionsFromAPI()
                }
            }
        }
    }
    
    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dataStore.deleteProject(dataStore.projects[index])
            }
        }
    }
}

struct ProjectRowView: View {
    let project: Project
    let runningAgents: Int
    let totalAgents: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Project Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(project.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if runningAgents > 0 {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                        value: runningAgents
                                    )
                            }
                            Text("\(runningAgents)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(project.workingDirectory)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        Text("\(totalAgents) sessions")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(project.createdAt, style: .date)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    ProjectsListView()
}