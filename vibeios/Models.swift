import Foundation

struct Project: Identifiable, Codable {
    let id = UUID()
    var name: String
    var workingDirectory: String
    var createdAt: Date
    var agents: [Agent]
    
    var runningAgentsCount: Int {
        agents.filter { $0.isRunning }.count
    }
    
    init(name: String, workingDirectory: String) {
        self.name = name
        self.workingDirectory = workingDirectory
        self.createdAt = Date()
        self.agents = []
    }
}

struct Agent: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var isRunning: Bool
    var progress: Double
    var lastPrompt: String?
    var lastResponse: String?
    var createdAt: Date
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
        self.isRunning = false
        self.progress = 0.0
        self.lastPrompt = nil
        self.lastResponse = nil
        self.createdAt = Date()
    }
}

enum AgentStatus {
    case idle
    case running
    case completed
    case error
}