import Foundation
import SwiftUI

class DataStore: ObservableObject {
    @Published var projects: [Project] = []
    
    static let shared = DataStore()
    
    private init() {
        loadSampleData()
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
    }
    
    func addAgent(to projectId: UUID, agent: Agent) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].agents.append(agent)
        }
    }
    
    func updateAgent(in projectId: UUID, agent: Agent) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
           let agentIndex = projects[projectIndex].agents.firstIndex(where: { $0.id == agent.id }) {
            projects[projectIndex].agents[agentIndex] = agent
        }
    }
    
    func deleteAgent(from projectId: UUID, agentId: UUID) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].agents.removeAll { $0.id == agentId }
        }
    }
    
    func startAgent(in projectId: UUID, agentId: UUID) {
        updateAgentRunningState(in: projectId, agentId: agentId, isRunning: true)
    }
    
    func stopAgent(in projectId: UUID, agentId: UUID) {
        updateAgentRunningState(in: projectId, agentId: agentId, isRunning: false)
    }
    
    private func updateAgentRunningState(in projectId: UUID, agentId: UUID, isRunning: Bool) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
           let agentIndex = projects[projectIndex].agents.firstIndex(where: { $0.id == agentId }) {
            projects[projectIndex].agents[agentIndex].isRunning = isRunning
            if isRunning {
                projects[projectIndex].agents[agentIndex].progress = 0.0
            }
        }
    }
    
    private func loadSampleData() {
        var sampleProject = Project(name: "AI Research Tool", workingDirectory: "/Users/sample/projects/ai-research")
        sampleProject.agents = [
            Agent(name: "Data Collector", description: "Collects research data from various sources"),
            Agent(name: "Text Analyzer", description: "Analyzes collected text for patterns and insights"),
            Agent(name: "Report Generator", description: "Generates comprehensive research reports")
        ]
        
        var webProject = Project(name: "Web Scraper Suite", workingDirectory: "/Users/sample/projects/web-scraper")
        webProject.agents = [
            Agent(name: "URL Crawler", description: "Crawls websites for specific content"),
            Agent(name: "Content Parser", description: "Parses and structures scraped content")
        ]
        
        projects = [sampleProject, webProject]
    }
}