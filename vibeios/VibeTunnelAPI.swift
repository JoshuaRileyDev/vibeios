//
//  VibeTunnelAPI.swift
//  VibeIOS - Terminal Session Management for iOS
//
//  Comprehensive API service for VibeTunnel server communication and terminal output parsing.
//  This file contains all networking logic, data models, and advanced terminal output analysis
//  for detecting AI session states, token counts, and running timers.
//
//  Created by Joshua Riley on 16/06/2025.
//

import Foundation

// MARK: - API Response Models

/**
 * Generic API response wrapper for VibeTunnel server responses
 * 
 * This structure handles the standard response format from the VibeTunnel API,
 * providing consistent access to success status, messages, errors, and data payloads.
 * The generic type T allows for different data payload types while maintaining
 * a consistent response structure.
 * 
 * Example JSON response:
 * {
 *   "success": true,
 *   "message": "Session created successfully",
 *   "sessionId": "abc123",
 *   "data": { ... }
 * }
 */
struct APIResponse<T: Codable>: Codable {
    /// Indicates whether the API operation was successful
    let success: Bool
    
    /// Optional human-readable message describing the operation result
    let message: String?
    
    /// Optional error message when success is false
    let error: String?
    
    /// Session identifier returned by session creation operations
    let sessionId: String?
    
    /// Generic data payload containing operation-specific results
    let data: T?
    
    /**
     * Custom decoder to handle optional fields and provide robust JSON parsing
     * 
     * This implementation ensures that the response can be parsed even if some
     * optional fields are missing from the server response, improving reliability
     * when working with different API versions or error conditions.
     */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
        data = try container.decodeIfPresent(T.self, forKey: .data)
    }
}

/**
 * Health check response model
 * 
 * Used to verify VibeTunnel server connectivity and operational status.
 * This simple response helps determine if the server is reachable and functioning.
 */
struct HealthResponse: Codable {
    /// Server operational status
    let success: Bool
    
    /// Server status message (e.g., "VibeTunnel server is running")
    let message: String
}

/**
 * Server information response model
 * 
 * Provides detailed information about the VibeTunnel server instance,
 * useful for debugging and compatibility verification.
 */
struct ServerInfo: Codable {
    /// Server software name
    let name: String
    
    /// Server version string for compatibility checking
    let version: String
    
    /// Server uptime in seconds since last restart
    let uptime: Double
}

/**
 * Terminal session data model
 * 
 * Represents a terminal session running on the VibeTunnel server.
 * Sessions are created in specific working directories and can execute
 * various commands including shell commands and AI tools like Claude Code.
 */
struct Session: Codable, Identifiable {
    // MARK: - Core Properties
    
    /// Unique session identifier assigned by the server
    let id: String
    
    /// Command used to start the session (e.g., "bash -l", "zsh")
    let command: String
    
    /// Working directory where the session was started
    let workingDir: String
    
    /// Current session status: "running", "exited", "stopped"
    let status: String
    
    /// Exit code if the session has terminated (nil for running sessions)
    let exitCode: Int?
    
    /// ISO 8601 timestamp when the session was created
    let startedAt: String
    
    /// ISO 8601 timestamp of the last session activity
    let lastModified: String
    
    /// Process ID of the session on the server (nil if not available)
    let pid: Int?
    
    // MARK: - Computed Properties
    
    /**
     * Determines if the session is currently running
     * 
     * This computed property provides a convenient boolean check for session status.
     * Running sessions can accept input and generate output, while non-running
     * sessions are either completed or terminated.
     * 
     * Returns: true if status is "running", false otherwise
     */
    var isRunning: Bool {
        return status.lowercased() == "running"
    }
    
    /**
     * Default session state for AI detection
     * 
     * This property returns a default idle state. The actual AI session state
     * is determined by analyzing terminal output using TerminalOutputParser.
     * This property exists for compatibility but should be replaced by dynamic
     * state detection based on real terminal output.
     * 
     * Returns: SessionState.idle as a default placeholder
     */
    var sessionState: SessionState {
        return SessionState.idle // Default, will be updated based on output
    }
}

/**
 * AI session state model for Claude Code detection
 * 
 * This model tracks the current state of AI interactions within terminal sessions.
 * It's populated by analyzing terminal output to detect when Claude Code or other
 * AI tools are actively running, including elapsed time and token consumption.
 */
struct SessionState {
    // MARK: - AI Activity Properties
    
    /// Indicates whether an AI tool (like Claude Code) is currently running
    let isAIRunning: Bool
    
    /// Number of seconds the AI has been running (parsed from terminal output)
    let runningSeconds: Int?
    
    /// Number of tokens consumed by the AI session (parsed from terminal output)
    let tokenCount: Int?
    
    /// True if the session shows no recent AI activity
    let isIdle: Bool
    
    // MARK: - Static Instances
    
    /// Default idle state when no AI activity is detected
    static let idle = SessionState(isAIRunning: false, runningSeconds: nil, tokenCount: nil, isIdle: true)
    
    // MARK: - Initialization
    
    /**
     * Creates a new session state with specified AI activity parameters
     * 
     * Parameters:
     * - isAIRunning: Whether AI is currently active
     * - runningSeconds: Elapsed time if AI is running
     * - tokenCount: Token consumption if available
     * - isIdle: Whether the session appears idle
     */
    init(isAIRunning: Bool, runningSeconds: Int?, tokenCount: Int?, isIdle: Bool) {
        self.isAIRunning = isAIRunning
        self.runningSeconds = runningSeconds
        self.tokenCount = tokenCount
        self.isIdle = isIdle
    }
}

/**
 * Session creation request model
 * 
 * Defines the parameters needed to create a new terminal session on the VibeTunnel server.
 * This model encapsulates all configuration options for session initialization.
 */
struct CreateSessionRequest: Codable {
    /// Command array to execute (e.g., ["bash", "-l"])
    let command: [String]
    
    /// Optional working directory (defaults to server's default if nil)
    let workingDir: String?
    
    /// Terminal type for compatibility (e.g., "xterm-256color")
    let term: String?
    
    /// Whether to spawn a visible terminal on the server (usually false for headless)
    let spawn_terminal: Bool?
    
    /**
     * Convenience initializer with default values
     * 
     * Parameters:
     * - command: Command array to execute
     * - workingDir: Optional working directory
     * - term: Terminal type (defaults to "xterm-256color")
     * - spawnTerminal: Whether to spawn visible terminal (defaults to false)
     */
    init(command: [String], workingDir: String? = nil, term: String = "xterm-256color", spawnTerminal: Bool = false) {
        self.command = command
        self.workingDir = workingDir
        self.term = term
        self.spawn_terminal = spawnTerminal
    }
}

/**
 * Input sending request model
 * 
 * Used to send text input (commands) to running terminal sessions.
 */
struct SendInputRequest: Codable {
    /// Text to send to the terminal session (usually includes \n for execution)
    let text: String
}

// MARK: - Ngrok Tunnel Models

/**
 * Ngrok tunnel status response model
 * 
 * Provides information about the current Ngrok tunnel state for public access
 * to the VibeTunnel server.
 */
struct NgrokStatus: Codable {
    /// Whether Ngrok tunnel is currently active
    let isActive: Bool
    
    /// Public URL of the tunnel (if active)
    let publicUrl: String?
    
    /// Detailed status information
    let status: NgrokStatusDetail?
}

/**
 * Detailed Ngrok status information
 */
struct NgrokStatusDetail: Codable {
    /// Public tunnel URL
    let publicUrl: String?
    
    /// Usage metrics for the tunnel
    let metrics: NgrokMetrics?
    
    /// When the tunnel was started
    let startedAt: String?
}

/**
 * Ngrok tunnel usage metrics
 */
struct NgrokMetrics: Codable {
    /// Number of connections made through the tunnel
    let connectionsCount: Int
    
    /// Bytes received through the tunnel
    let bytesIn: Int
    
    /// Bytes sent through the tunnel
    let bytesOut: Int
}

// MARK: - File System Models

/**
 * File system item model for directory browsing
 * 
 * Represents files and directories when browsing the server's file system.
 */
struct FileSystemItem: Codable {
    /// File or directory name
    let name: String
    
    /// Creation timestamp
    let created: String
    
    /// Last modification timestamp
    let lastModified: String
    
    /// Size in bytes (0 for directories)
    let size: Int
    
    /// True if this item is a directory
    let isDir: Bool
}

/**
 * Directory browse response model
 * 
 * Contains the result of browsing a directory on the server.
 */
struct BrowseResponse: Codable {
    /// Absolute path of the browsed directory
    let absolutePath: String
    
    /// Array of files and subdirectories
    let files: [FileSystemItem]
}

// MARK: - API Service

/**
 * VibeTunnel API service singleton
 * 
 * This class manages all communication with the VibeTunnel server, including:
 * - Session management (create, list, kill, cleanup)
 * - Terminal I/O (send commands, get output)
 * - Server health monitoring
 * - File system browsing
 * - Ngrok tunnel management
 * 
 * The service is designed as an ObservableObject to integrate with SwiftUI's
 * reactive architecture, automatically updating the UI when connection status changes.
 */
class VibeTunnelAPIService: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Base URL of the VibeTunnel server (e.g., "http://localhost:8080")
    @Published var baseURL: String = UserDefaults.standard.string(forKey: "vibetunnel_base_url") ?? "http://localhost:8080"
    
    /// Current connection status to the server
    @Published var isConnected: Bool = false
    
    /// Username for basic authentication (if required)
    @Published var username: String = UserDefaults.standard.string(forKey: "vibetunnel_username") ?? ""
    
    /// Password for basic authentication (if required)
    @Published var password: String = UserDefaults.standard.string(forKey: "vibetunnel_password") ?? ""
    
    // MARK: - Private Properties
    
    /// URL session for making HTTP requests
    private let session = URLSession.shared
    
    /// Singleton instance for global access
    static let shared = VibeTunnelAPIService()
    
    // MARK: - Initialization
    
    /**
     * Private initializer to enforce singleton pattern
     * 
     * Automatically checks connection status when initialized and loads
     * saved configuration from UserDefaults.
     */
    private init() {
        Task {
            await checkConnection()
        }
    }
    
    // MARK: - Configuration Methods
    
    /**
     * Updates the base URL and tests the new connection
     * 
     * This method updates both the runtime configuration and persists the
     * new URL to UserDefaults for future app launches.
     * 
     * Parameter url: New base URL for the VibeTunnel server
     */
    func updateBaseURL(_ url: String) {
        baseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(baseURL, forKey: "vibetunnel_base_url")
        Task {
            await checkConnection()
        }
    }
    
    /**
     * Updates authentication credentials
     * 
     * Stores both username and password in UserDefaults for persistence.
     * These credentials are used for basic HTTP authentication if the server requires it.
     * 
     * Parameters:
     * - username: Authentication username
     * - password: Authentication password
     */
    func updateCredentials(username: String, password: String) {
        self.username = username
        self.password = password
        UserDefaults.standard.set(username, forKey: "vibetunnel_username")
        UserDefaults.standard.set(password, forKey: "vibetunnel_password")
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * Creates a configured URLRequest for API endpoints
     * 
     * This method handles common request configuration including:
     * - URL construction from base URL and endpoint
     * - HTTP method setting
     * - Content-Type headers
     * - Basic authentication if credentials are provided
     * 
     * Parameters:
     * - endpoint: API endpoint path (e.g., "/api/sessions")
     * - method: HTTP method (defaults to "GET")
     * 
     * Returns: Configured URLRequest or nil if URL is invalid
     */
    private func createRequest(for endpoint: String, method: String = "GET") -> URLRequest? {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add basic auth if credentials are provided
        if !username.isEmpty && !password.isEmpty {
            let credentials = "\(username):\(password)"
            if let credentialData = credentials.data(using: .utf8) {
                let base64Credentials = credentialData.base64EncodedString()
                request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    /**
     * Performs an HTTP request and decodes the JSON response
     * 
     * This generic method handles the common pattern of:
     * - Executing the HTTP request
     * - Validating the HTTP response status
     * - Decoding the JSON response to the specified type
     * - Converting errors to appropriate APIError types
     * 
     * Parameters:
     * - request: Configured URLRequest to execute
     * - responseType: Type to decode the response to
     * 
     * Returns: Decoded response of the specified type
     * Throws: APIError for various failure conditions
     */
    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Health & Connection Methods
    
    /**
     * Checks server connectivity and updates the published isConnected property
     * 
     * This method is called automatically during initialization and whenever
     * the base URL changes. It performs a health check and updates the UI
     * accordingly through the @Published property.
     */
    @MainActor
    func checkConnection() {
        Task {
            do {
                _ = try await healthCheck()
                isConnected = true
            } catch {
                isConnected = false
            }
        }
    }
    
    /**
     * Performs a health check against the VibeTunnel server
     * 
     * Returns: HealthResponse indicating server status
     * Throws: APIError if the server is unreachable or returns an error
     */
    func healthCheck() async throws -> HealthResponse {
        guard let request = createRequest(for: "/api/health") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: HealthResponse.self)
    }
    
    /**
     * Retrieves detailed server information
     * 
     * Returns: ServerInfo with version, uptime, and other details
     * Throws: APIError if the request fails
     */
    func getServerInfo() async throws -> ServerInfo {
        guard let request = createRequest(for: "/info") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: ServerInfo.self)
    }
    
    // MARK: - Session Management Methods
    
    /**
     * Retrieves all terminal sessions from the server
     * 
     * Returns: Array of Session objects representing all active and completed sessions
     * Throws: APIError if the request fails
     */
    func listSessions() async throws -> [Session] {
        guard let request = createRequest(for: "/api/sessions") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: [Session].self)
    }
    
    /**
     * Creates a new terminal session on the server
     * 
     * This method sends a session creation request to the server with the specified
     * parameters. The server will start a new terminal process in the given working
     * directory and return a session ID for further interaction.
     * 
     * Parameters:
     * - command: Command array to execute (e.g., ["bash", "-l"])
     * - workingDir: Optional working directory for the session
     * - term: Terminal type for compatibility (defaults to "xterm-256color")
     * - spawnTerminal: Whether to spawn a visible terminal (defaults to false)
     * 
     * Returns: APIResponse containing the new session ID
     * Throws: APIError if session creation fails
     */
    func createSession(command: [String], workingDir: String? = nil, term: String = "xterm-256color", spawnTerminal: Bool = false) async throws -> APIResponse<String> {
        guard var request = createRequest(for: "/api/sessions", method: "POST") else {
            throw APIError.invalidURL
        }
        
        let sessionRequest = CreateSessionRequest(command: command, workingDir: workingDir, term: term, spawnTerminal: spawnTerminal)
        request.httpBody = try JSONEncoder().encode(sessionRequest)
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Sends text input to a running terminal session
     * 
     * This method allows sending commands or text to a terminal session. The text
     * is sent exactly as provided, so include "\n" for command execution.
     * 
     * Parameters:
     * - sessionId: ID of the target session
     * - text: Text to send (usually includes \n for execution)
     * 
     * Returns: APIResponse indicating success or failure
     * Throws: APIError if the request fails
     */
    func sendInput(to sessionId: String, text: String) async throws -> APIResponse<String> {
        guard var request = createRequest(for: "/api/sessions/\(sessionId)/input", method: "POST") else {
            throw APIError.invalidURL
        }
        
        let inputRequest = SendInputRequest(text: text)
        request.httpBody = try JSONEncoder().encode(inputRequest)
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Retrieves current terminal output from a session
     * 
     * This method returns the current terminal buffer content, which can be parsed
     * to determine session state, extract command output, and detect AI activity.
     * 
     * Parameter sessionId: ID of the session to read
     * 
     * Returns: Raw terminal output as a string
     * Throws: APIError if the request fails
     */
    func getSessionSnapshot(sessionId: String) async throws -> String {
        guard let request = createRequest(for: "/api/sessions/\(sessionId)/snapshot") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /**
     * Terminates a running terminal session
     * 
     * Sends a kill signal to the session process, stopping it immediately.
     * The session will transition to "exited" status.
     * 
     * Parameter sessionId: ID of the session to terminate
     * 
     * Returns: APIResponse indicating success or failure
     * Throws: APIError if the request fails
     */
    func killSession(sessionId: String) async throws -> APIResponse<String> {
        guard let request = createRequest(for: "/api/sessions/\(sessionId)", method: "DELETE") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Cleans up a terminated session from the server
     * 
     * Removes session data and resources for sessions that have exited.
     * This helps free up server resources and clean up the session list.
     * 
     * Parameter sessionId: ID of the session to clean up
     * 
     * Returns: APIResponse indicating success or failure
     * Throws: APIError if the request fails
     */
    func cleanupSession(sessionId: String) async throws -> APIResponse<String> {
        guard let request = createRequest(for: "/api/sessions/\(sessionId)/cleanup", method: "DELETE") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Cleans up all exited sessions at once
     * 
     * Bulk operation to clean up all sessions that have terminated,
     * helping maintain a clean session list and free server resources.
     * 
     * Returns: APIResponse indicating success or failure
     * Throws: APIError if the request fails
     */
    func cleanupAllExitedSessions() async throws -> APIResponse<String> {
        guard let request = createRequest(for: "/api/cleanup-exited", method: "POST") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    // MARK: - File System Methods
    
    /**
     * Browses a directory on the server
     * 
     * Allows exploration of the server's file system to help users navigate
     * and select appropriate working directories for their projects.
     * 
     * Parameter path: Optional path to browse (defaults to server's default directory)
     * 
     * Returns: BrowseResponse containing directory contents
     * Throws: APIError if the request fails
     */
    func browseDirectory(path: String? = nil) async throws -> BrowseResponse {
        var endpoint = "/api/fs/browse"
        if let path = path {
            endpoint += "?path=\(path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        guard let request = createRequest(for: endpoint) else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: BrowseResponse.self)
    }
    
    // MARK: - Ngrok Tunnel Methods
    
    /**
     * Starts an Ngrok tunnel for public access
     * 
     * Creates a public tunnel to the VibeTunnel server, allowing external access
     * for collaboration or remote access scenarios.
     * 
     * Returns: APIResponse with tunnel information
     * Throws: APIError if tunnel creation fails
     */
    func startNgrokTunnel() async throws -> APIResponse<String> {
        guard let request = createRequest(for: "/api/ngrok/start", method: "POST") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Stops the active Ngrok tunnel
     * 
     * Terminates the public tunnel, returning the server to local-only access.
     * 
     * Returns: APIResponse indicating success or failure
     * Throws: APIError if the request fails
     */
    func stopNgrokTunnel() async throws -> APIResponse<String> {
        guard let request = createRequest(for: "/api/ngrok/stop", method: "POST") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: APIResponse<String>.self)
    }
    
    /**
     * Retrieves current Ngrok tunnel status
     * 
     * Returns information about the tunnel state, public URL, and usage metrics.
     * 
     * Returns: NgrokStatus with current tunnel information
     * Throws: APIError if the request fails
     */
    func getNgrokStatus() async throws -> NgrokStatus {
        guard let request = createRequest(for: "/api/ngrok/status") else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(request, responseType: NgrokStatus.self)
    }
}

// MARK: - Terminal Output Parser

/**
 * Advanced terminal output parser for AI session detection
 * 
 * This class provides sophisticated parsing of terminal output to detect when
 * AI tools like Claude Code are running, extract timing information, and
 * determine token consumption. It handles various output formats including
 * JSON-formatted terminal data and traditional ANSI terminal output.
 * 
 * Key Features:
 * - Detects Claude Code running states from terminal patterns
 * - Extracts elapsed time from timestamp data
 * - Parses token consumption information
 * - Cleans ANSI escape sequences for better parsing
 * - Handles Unicode character normalization
 * - Supports multiple output formats and patterns
 */
class TerminalOutputParser {
    
    /**
     * Main method to parse terminal output and determine session state
     * 
     * This method analyzes terminal output to determine if AI tools are running,
     * how long they've been active, and how many tokens have been consumed.
     * It uses multiple parsing strategies to handle different output formats.
     * 
     * Algorithm:
     * 1. Split output into lines for analysis
     * 2. Scan from newest to oldest output for recent activity
     * 3. Look for JSON timestamp patterns indicating real-time activity
     * 4. Search for Claude Code specific patterns and indicators
     * 5. Extract timing and token information when available
     * 6. Determine overall session state based on findings
     * 
     * Parameter output: Raw terminal output string to analyze
     * 
     * Returns: SessionState indicating AI activity, timing, and token usage
     */
    static func parseSessionState(from output: String) -> SessionState {
        let lines = output.components(separatedBy: .newlines)
        
        // Initialize state tracking variables
        var runningSeconds: Int? = nil
        var tokenCount: Int? = nil
        var isAIRunning = false
        
        // Track the most recent activity indicators
        var latestTimestamp: Int? = nil
        var foundTokens: Int? = nil
        var hasRecentActivity = false
        
        // Analyze lines from newest to oldest for most recent state
        for line in lines.reversed() {
            let cleanLine = cleanTerminalOutput(line)
            
            // First priority: Look for explicit Claude running patterns
            if let match = parseClaudeRunningPattern(line) {
                latestTimestamp = match.seconds
                foundTokens = match.tokens
                isAIRunning = true
                break // Found definitive running state
            }
            
            // Second priority: Look for JSON timestamp patterns indicating activity
            let timestampPattern = #"\[(\d+)\.[\d]+,"o""#
            do {
                let regex = try NSRegularExpression(pattern: timestampPattern, options: [])
                let range = NSRange(location: 0, length: line.utf16.count)
                
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let secondsRange = Range(match.range(at: 1), in: line)
                    if let secondsRange = secondsRange,
                       let seconds = Int(String(line[secondsRange])) {
                        if latestTimestamp == nil || seconds > (latestTimestamp ?? 0) {
                            latestTimestamp = seconds
                            hasRecentActivity = true
                        }
                    }
                }
            } catch {
                // Continue with other parsing methods
            }
            
            // Third priority: Look for traditional Claude patterns
            if cleanLine.contains("esc to interrupt") || 
               cleanLine.contains("Tool Use:") || 
               cleanLine.contains("Human:") || 
               cleanLine.contains("Assistant:") {
                hasRecentActivity = true
                
                // Try to extract timing and token information from this line
                if let timeMatch = extractTimeFromLine(cleanLine) {
                    latestTimestamp = timeMatch
                }
                if let tokenMatch = extractTokensFromLine(cleanLine) {
                    foundTokens = tokenMatch
                }
            }
            
            // Pattern indicating task completion (usually means AI finished)
            if cleanLine.contains("⏺") && !cleanLine.contains("(") {
                hasRecentActivity = true
                break // AI finished a task
            }
        }
        
        // Determine final state based on analysis
        if let timestamp = latestTimestamp {
            runningSeconds = timestamp
            tokenCount = foundTokens ?? estimateTokensFromOutput(output)
            
            // Consider AI as running if we have very recent activity or explicit indicators
            isAIRunning = hasRecentActivity || (foundTokens != nil)
        }
        
        let isIdle = !isAIRunning
        return SessionState(
            isAIRunning: isAIRunning,
            runningSeconds: runningSeconds,
            tokenCount: tokenCount,
            isIdle: isIdle
        )
    }
    
    /**
     * Parses Claude Code specific running patterns from terminal output
     * 
     * This method looks for specific patterns that indicate Claude Code is actively
     * running, including timestamp formats and token consumption indicators.
     * It handles both JSON-formatted terminal data and traditional text patterns.
     * 
     * Supported patterns:
     * - JSON timestamp format: [2637.05856875,"o","..."]
     * - Traditional format: "✽ Documenting… (157s · ↑ 416 tokens · esc to interrupt)"
     * - Various regex patterns for different Claude output formats
     * 
     * Parameter line: Single line of terminal output to analyze
     * 
     * Returns: Tuple containing seconds and tokens if pattern is found, nil otherwise
     */
    private static func parseClaudeRunningPattern(_ line: String) -> (seconds: Int, tokens: Int)? {
        // Handle JSON timestamp format first
        // Format: [2637.05856875,"o","content"] where 2637 represents seconds
        let timestampPattern = #"\[(\d+)\.[\d]+,"o",".*?\]"#
        
        do {
            let regex = try NSRegularExpression(pattern: timestampPattern, options: [])
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if let match = regex.firstMatch(in: line, options: [], range: range) {
                let secondsRange = Range(match.range(at: 1), in: line)
                if let secondsRange = secondsRange,
                   let seconds = Int(String(line[secondsRange])) {
                    // For timestamp-based parsing, estimate tokens from activity
                    return (seconds: seconds, tokens: estimateTokensFromOutput(line))
                }
            }
        } catch {
            // Continue to traditional pattern matching
        }
        
        // Clean the line of ANSI escape codes for pattern matching
        let cleanLine = cleanTerminalOutput(line)
        
        // Traditional Claude Code patterns
        // Format: "✽ Documenting… (157s · ↑ 416 tokens · esc to interrupt)"
        let patterns = [
            #".*\((\d+)s.*?↑?\s*(\d+)\s*tokens.*\)"#,  // Full format with tokens
            #".*(\d+)s.*?(\d+)\s*tokens"#,              // Simplified format
            #".*\((\d+)s.*?(\d+)\s*tok"#,               // Abbreviated tokens
            #".*(\d+)s.*?(\d+)\s*(?:token|tok)"#        // Various token formats
        ]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let range = NSRange(location: 0, length: cleanLine.utf16.count)
                
                if let match = regex.firstMatch(in: cleanLine, options: [], range: range) {
                    let secondsRange = Range(match.range(at: 1), in: cleanLine)
                    let tokensRange = Range(match.range(at: 2), in: cleanLine)
                    
                    if let secondsRange = secondsRange,
                       let tokensRange = tokensRange,
                       let seconds = Int(String(cleanLine[secondsRange])),
                       let tokens = Int(String(cleanLine[tokensRange])) {
                        return (seconds: seconds, tokens: tokens)
                    }
                }
            } catch {
                // Try next pattern if regex fails
                continue
            }
        }
        
        return nil
    }
    
    /**
     * Estimates token count from terminal output
     * 
     * When explicit token counts aren't available, this method attempts to
     * extract or estimate token usage from the terminal output content.
     * 
     * Parameter line: Terminal output to analyze for token information
     * 
     * Returns: Estimated token count (with reasonable bounds)
     */
    private static func estimateTokensFromOutput(_ line: String) -> Int {
        // Look for explicit token numbers in various formats
        let tokenPatterns = [
            #"(\d+)\s*tokens?"#,  // "416 tokens" or "416 token"
            #"↑\s*(\d+)"#,        // "↑ 416"
            #"tokens?\s*(\d+)"#   // "tokens 416"
        ]
        
        for pattern in tokenPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let range = NSRange(location: 0, length: line.utf16.count)
                
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let tokenRange = Range(match.range(at: 1), in: line)
                    if let tokenRange = tokenRange,
                       let tokens = Int(String(line[tokenRange])) {
                        return tokens
                    }
                }
            } catch {
                continue
            }
        }
        
        // Fallback: Rough estimation based on output length
        // This provides a reasonable estimate when no explicit count is available
        return min(500, max(100, line.count / 4))
    }
    
    /**
     * Comprehensive terminal output cleaning function
     * 
     * This method removes ANSI escape sequences, normalizes Unicode characters,
     * and handles JSON-formatted terminal data to produce clean text suitable
     * for pattern matching and analysis.
     * 
     * Cleaning operations:
     * 1. Extract content from JSON-formatted terminal data
     * 2. Remove various ANSI escape sequence patterns
     * 3. Remove control characters (ESC, carriage return, etc.)
     * 4. Normalize Unicode character composition
     * 5. Replace special Unicode characters with ASCII equivalents
     * 6. Clean up excessive whitespace and newlines
     * 
     * Parameter text: Raw terminal output to clean
     * 
     * Returns: Cleaned text suitable for pattern matching
     */
    private static func cleanTerminalOutput(_ text: String) -> String {
        var cleaned = text
        
        // First, handle JSON-like format [timestamp,"o","content"]
        let jsonPattern = #"\[[\d.]+,"o","(.*?)"\]"#
        do {
            let regex = try NSRegularExpression(pattern: jsonPattern, options: [.dotMatchesLineSeparators])
            let matches = regex.matches(in: cleaned, options: [], range: NSRange(location: 0, length: cleaned.utf16.count))
            
            var extractedContent = ""
            for match in matches {
                if match.numberOfRanges > 1 {
                    let contentRange = Range(match.range(at: 1), in: cleaned)
                    if let contentRange = contentRange {
                        let content = String(cleaned[contentRange])
                        extractedContent += content
                    }
                }
            }
            
            // Use extracted JSON content if available
            if !extractedContent.isEmpty {
                cleaned = extractedContent
            }
        } catch {
            // Continue with original cleaning approach
        }
        
        // Remove various ANSI escape sequence patterns
        let ansiPatterns = [
            #"\u001b\[[0-9;]*[a-zA-Z]"#,      // Standard ANSI codes
            #"\u001b\[[0-9]*[A-Za-z]"#,       // Simple ANSI codes
            #"\u001b\[[\d;]*m"#,              // Color codes specifically
            #"\u001b\[[0-9]*[ABCDEFGHJKLMNPQRSTUVWXYZ]"#  // All ANSI commands
        ]
        
        for pattern in ansiPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                cleaned = regex.stringByReplacingMatches(
                    in: cleaned,
                    options: [],
                    range: NSRange(location: 0, length: cleaned.utf16.count),
                    withTemplate: ""
                )
            } catch {
                // Continue with next pattern if regex fails
            }
        }
        
        // Remove control characters
        cleaned = cleaned.replacingOccurrences(of: "\u{1b}", with: "")    // ESC character
        cleaned = cleaned.replacingOccurrences(of: "\u{000D}", with: "")  // Carriage return
        cleaned = cleaned.replacingOccurrences(of: "\u{000A}", with: "\n") // Line feed
        
        // Normalize Unicode characters for consistent processing
        cleaned = cleaned.precomposedStringWithCanonicalMapping
        
        // Replace special Unicode characters with ASCII equivalents
        cleaned = cleaned.replacingOccurrences(of: "…", with: "...")  // Ellipsis
        cleaned = cleaned.replacingOccurrences(of: "·", with: "·")    // Middle dot
        cleaned = cleaned.replacingOccurrences(of: "↑", with: "^")    // Up arrow
        
        // Clean up excessive whitespace and newlines
        cleaned = cleaned.replacingOccurrences(of: "\n\n+", with: "\n", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    /**
     * Extracts time information from a line of terminal output
     * 
     * Looks for patterns indicating elapsed time in seconds, such as "157s" or "2421s".
     * 
     * Parameter line: Line of terminal output to analyze
     * 
     * Returns: Extracted time in seconds, or nil if not found
     */
    private static func extractTimeFromLine(_ line: String) -> Int? {
        let timePattern = #"(\d+)s"#
        
        do {
            let regex = try NSRegularExpression(pattern: timePattern, options: [])
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if let match = regex.firstMatch(in: line, options: [], range: range) {
                let timeRange = Range(match.range(at: 1), in: line)
                if let timeRange = timeRange {
                    return Int(String(line[timeRange]))
                }
            }
        } catch {
            // Regex parsing failed
        }
        
        return nil
    }
    
    /**
     * Extracts token information from a line of terminal output
     * 
     * Searches for various patterns indicating token consumption, such as
     * "416 tokens", "↑ 416", or abbreviated forms.
     * 
     * Parameter line: Line of terminal output to analyze
     * 
     * Returns: Extracted token count, or nil if not found
     */
    private static func extractTokensFromLine(_ line: String) -> Int? {
        let tokenPatterns = [
            #"(\d+)\s*tokens"#,  // "416 tokens"
            #"(\d+)\s*tok"#,     // "416 tok" (abbreviated)
            #"↑\s*(\d+)"#,       // "↑ 416" (up arrow format)
            #"\^\s*(\d+)"#       // "^ 416" (ASCII up arrow)
        ]
        
        for pattern in tokenPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let range = NSRange(location: 0, length: line.utf16.count)
                
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let tokenRange = Range(match.range(at: 1), in: line)
                    if let tokenRange = tokenRange {
                        return Int(String(line[tokenRange]))
                    }
                }
            } catch {
                // Try next pattern if regex fails
                continue
            }
        }
        
        return nil
    }
}

// MARK: - Error Types

/**
 * API error enumeration for comprehensive error handling
 * 
 * This enum provides specific error types for different failure conditions
 * when communicating with the VibeTunnel API, enabling appropriate user
 * feedback and error recovery strategies.
 */
enum APIError: LocalizedError {
    /// Invalid URL construction or malformed endpoint
    case invalidURL
    
    /// Invalid or unexpected response format from server
    case invalidResponse
    
    /// HTTP error with specific status code
    case httpError(Int)
    
    /// JSON decoding failure with underlying error
    case decodingError(Error)
    
    /// Network-level error (connectivity, timeout, etc.)
    case networkError(Error)
    
    /**
     * Provides localized error descriptions for user display
     * 
     * Returns human-readable error messages appropriate for showing to users
     * in alerts or error states within the app interface.
     */
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}