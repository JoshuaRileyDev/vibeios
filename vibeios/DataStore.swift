//
//  DataStore.swift
//  VibeIOS - Terminal Session Management for iOS
//
//  Centralized data management and state coordination for the application.
//  This singleton class manages projects, sessions, and provides integration
//  with the VibeTunnel API for remote session management.
//
//  Created by Joshua Riley on 16/06/2025.
//

import Foundation
import SwiftUI

/**
 * Centralized data store for application state management
 * 
 * This class serves as the single source of truth for all application data,
 * including projects and terminal sessions. It coordinates between local
 * data persistence and remote API operations, providing a clean interface
 * for SwiftUI views to observe and modify application state.
 * 
 * Key Responsibilities:
 * - Local project storage and persistence using UserDefaults
 * - Remote session management through VibeTunnel API integration
 * - State synchronization between local and remote data
 * - Reactive data updates for SwiftUI view binding
 * - Session filtering and organization by project context
 * 
 * Architecture Pattern:
 * This follows the MVVM (Model-View-ViewModel) pattern where DataStore
 * acts as the shared ViewModel layer, providing ObservableObject conformance
 * for automatic UI updates when data changes.
 */
class DataStore: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Array of all user-created projects
    /// Published property automatically triggers UI updates when projects change
    @Published var projects: [Project] = []
    
    /// Array of all terminal sessions from the VibeTunnel server
    /// Updated through API calls and filtered by project for display
    @Published var allSessions: [Session] = []
    
    // MARK: - Private Properties
    
    /// Shared singleton instance for global data access
    static let shared = DataStore()
    
    /// VibeTunnel API service for remote session operations
    private let apiService = VibeTunnelAPIService.shared
    
    /// UserDefaults for persistent local storage
    private let userDefaults = UserDefaults.standard
    
    /// UserDefaults key for project storage
    private let projectsKey = "saved_projects"
    
    // MARK: - Initialization
    
    /**
     * Private initializer to enforce singleton pattern
     * 
     * Automatically loads projects from persistent storage and initiates
     * the first session refresh from the API. The singleton pattern ensures
     * consistent data state across the entire application.
     */
    private init() {
        loadProjects()
        loadSessionsFromAPI()
    }
    
    // MARK: - Project Management Methods
    
    /**
     * Adds a new project to the collection and persists it
     * 
     * This method adds the project to the local array and immediately
     * persists the change to UserDefaults. The @Published property
     * will automatically notify any observing SwiftUI views.
     * 
     * Parameter project: New project to add to the collection
     */
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    /**
     * Removes a project from the collection and persists the change
     * 
     * Removes the project with matching ID from the local array and
     * persists the updated collection. Sessions associated with the
     * deleted project remain on the server but will no longer be
     * displayed in the UI.
     * 
     * Parameter project: Project to remove from the collection
     */
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    // MARK: - VibeTunnel API Integration
    
    /**
     * Loads terminal sessions from the VibeTunnel API
     * 
     * This method performs an asynchronous API call to retrieve all
     * terminal sessions from the server. It only executes if the API
     * service reports a successful connection to avoid unnecessary
     * network requests and error states.
     * 
     * The method uses Task to handle the async/await pattern and
     * updates the UI on the main actor to ensure thread safety.
     */
    func loadSessionsFromAPI() {
        guard apiService.isConnected else { return }
        
        Task {
            do {
                let sessions = try await apiService.listSessions()
                await MainActor.run {
                    self.allSessions = sessions
                }
            } catch {
                print("Error loading sessions: \(error)")
            }
        }
    }
    
    /**
     * Retrieves running sessions associated with a specific project
     * 
     * Filters the complete session list to return only sessions that:
     * 1. Are running in the project's working directory
     * 2. Have a status of "running" (excluding exited or stopped sessions)
     * 
     * This method provides the primary data source for project detail views
     * to display active sessions without showing terminated ones.
     * 
     * Parameter project: Project to filter sessions for
     * 
     * Returns: Array of running sessions in the project's directory
     */
    func getSessionsForProject(_ project: Project) -> [Session] {
        // Only return running sessions to keep the UI clean
        return allSessions.filter { session in
            session.workingDir == project.workingDirectory && session.status.lowercased() == "running"
        }
    }
    
    /**
     * Alias method for getting running sessions for a project
     * 
     * This method provides the same functionality as getSessionsForProject
     * but with a more explicit name. It exists for API compatibility and
     * clarity in contexts where the running status is important.
     * 
     * Parameter project: Project to filter sessions for
     * 
     * Returns: Array of running sessions in the project's directory
     */
    func getRunningSessionsForProject(_ project: Project) -> [Session] {
        // This is now the same as getSessionsForProject since we only show running sessions
        return getSessionsForProject(project)
    }
    
    /**
     * Creates a new terminal session for a project
     * 
     * This method performs several operations to create and initialize a new session:
     * 1. Parses the command string into an array for API compatibility
     * 2. Sends session creation request to VibeTunnel API
     * 3. Validates the response and extracts the session ID
     * 4. Waits for session initialization on the server
     * 5. Refreshes the session list to include the new session
     * 6. Returns a temporary session object for immediate UI feedback
     * 
     * The temporary session object allows the UI to show immediate feedback
     * while the actual session data is being retrieved from the server.
     * 
     * Parameters:
     * - project: Project context for the new session
     * - command: Shell command to execute (will be parsed into array)
     * 
     * Returns: Session object representing the created session
     * Throws: APIError if session creation fails
     */
    func createSession(for project: Project, command: String) async throws -> Session {
        // Parse command string into array format expected by API
        let commandArray = command.split(separator: " ").map(String.init)
        
        // Create session request with project's working directory
        let response = try await apiService.createSession(
            command: commandArray.isEmpty ? ["bash", "-l"] : Array(commandArray),
            workingDir: project.workingDirectory,
            term: "xterm-256color",
            spawnTerminal: false
        )
        
        // Validate that we received a session ID
        guard let sessionId = response.sessionId else {
            throw APIError.invalidResponse
        }
        
        // Wait for session to be fully initialized on the server
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Refresh sessions to get the new one from the server
        await refreshSessionsFromAPI()
        
        // Return a temporary session object for immediate UI feedback
        // The real session data will come from the API refresh above
        return Session(
            id: sessionId,
            command: commandArray.joined(separator: " "),
            workingDir: project.workingDirectory,
            status: "running",
            exitCode: nil,
            startedAt: ISO8601DateFormatter().string(from: Date()),
            lastModified: ISO8601DateFormatter().string(from: Date()),
            pid: nil
        )
    }
    
    /**
     * Refreshes session data from the API on the main actor
     * 
     * This method ensures that session updates happen on the main thread
     * to maintain UI consistency. It's marked with @MainActor to guarantee
     * that the @Published property updates occur on the main queue.
     * 
     * The method guards against API calls when not connected to avoid
     * unnecessary network errors and maintains consistent error handling.
     */
    @MainActor
    func refreshSessionsFromAPI() async {
        guard apiService.isConnected else { return }
        
        do {
            let sessions = try await apiService.listSessions()
            self.allSessions = sessions
        } catch {
            print("Error loading sessions: \(error)")
        }
    }
    
    // MARK: - Local Storage Methods
    
    /**
     * Persists the current projects array to UserDefaults
     * 
     * Encodes the projects array to JSON and stores it in UserDefaults
     * for persistence across app launches. Uses the Codable protocol
     * for reliable serialization of the Project model.
     * 
     * Error handling is implemented to gracefully handle encoding
     * failures without crashing the app, though such failures should
     * be rare with the simple Project model structure.
     */
    private func saveProjects() {
        do {
            let data = try JSONEncoder().encode(projects)
            userDefaults.set(data, forKey: projectsKey)
        } catch {
            print("Error saving projects: \(error)")
        }
    }
    
    /**
     * Loads projects from UserDefaults or initializes with sample data
     * 
     * Attempts to decode projects from persistent storage. If no saved
     * data exists or decoding fails, it initializes with sample data
     * to provide a good first-run experience for new users.
     * 
     * The method handles various failure scenarios gracefully:
     * - No saved data (first run): loads sample data
     * - Corrupted data: loads sample data as fallback
     * - Decoding errors: loads sample data as fallback
     */
    private func loadProjects() {
        guard let data = userDefaults.data(forKey: projectsKey) else {
            loadSampleData()
            return
        }
        
        do {
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Error loading projects: \(error)")
            loadSampleData()
        }
    }
    
    /**
     * Initializes the app with empty projects for new users
     * 
     * This method sets up a clean state for new installations,
     * allowing users to create their own projects without being
     * overwhelmed by sample data. The empty state encourages
     * users to create projects that match their actual workflow.
     * 
     * The method immediately persists the empty state to ensure
     * consistency across app launches.
     */
    private func loadSampleData() {
        // Start with empty projects - user will create their own
        projects = []
        saveProjects()
    }
}

// MARK: - DataStore Extensions

/**
 * Convenience methods and computed properties for DataStore
 * 
 * These extensions provide additional functionality without cluttering
 * the main class definition, following Swift best practices for
 * code organization and readability.
 */
extension DataStore {
    
    /**
     * Returns the total count of running sessions across all projects
     * 
     * This computed property provides a quick way to get an overview
     * of system activity without iterating through all projects and
     * sessions manually. Useful for dashboard displays and status indicators.
     * 
     * Returns: Total number of running sessions
     */
    var totalRunningSessions: Int {
        return allSessions.filter { $0.status.lowercased() == "running" }.count
    }
    
    /**
     * Returns projects sorted by creation date (newest first)
     * 
     * Provides a consistently sorted view of projects for UI display,
     * ensuring that the most recently created projects appear at the
     * top of lists for better user experience.
     * 
     * Returns: Array of projects sorted by creation date (descending)
     */
    var sortedProjects: [Project] {
        return projects.sorted { $0.createdAt > $1.createdAt }
    }
    
    /**
     * Finds a project by its unique identifier
     * 
     * Convenience method for finding projects when working with session
     * navigation or when receiving project IDs from other parts of the app.
     * 
     * Parameter id: UUID of the project to find
     * 
     * Returns: Project with matching ID, or nil if not found
     */
    func project(withId id: UUID) -> Project? {
        return projects.first { $0.id == id }
    }
    
    /**
     * Returns session count for a specific project
     * 
     * Convenience method that encapsulates the filtering logic for
     * getting session counts, useful for UI badges and summary displays.
     * 
     * Parameter project: Project to count sessions for
     * 
     * Returns: Number of running sessions for the project
     */
    func sessionCount(for project: Project) -> Int {
        return getSessionsForProject(project).count
    }
}

// MARK: - Error Handling Extensions

/**
 * Error handling utilities for DataStore operations
 */
extension DataStore {
    
    /**
     * Handles session creation errors with user-friendly messages
     * 
     * Converts technical API errors into user-readable messages that can
     * be displayed in the UI. This centralizes error message formatting
     * and ensures consistent error presentation across the app.
     * 
     * Parameter error: The original error from session creation
     * 
     * Returns: User-friendly error message string
     */
    func userFriendlyErrorMessage(for error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "Invalid server configuration. Please check your settings."
            case .invalidResponse:
                return "Unexpected response from server. Please try again."
            case .httpError(let code):
                return "Server error (\(code)). Please check your connection."
            case .decodingError:
                return "Data format error. The server may be incompatible."
            case .networkError:
                return "Network connection failed. Please check your internet."
            }
        } else {
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}