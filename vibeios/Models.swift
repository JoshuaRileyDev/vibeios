//
//  Models.swift
//  VibeIOS - Terminal Session Management for iOS
//
//  Core data models for the application.
//  Defines the structure for projects and related entities used throughout the app.
//
//  Created by Joshua Riley on 16/06/2025.
//

import Foundation

/**
 * Project data model representing a development project
 * 
 * A Project serves as a container for organizing terminal sessions and represents
 * a specific development environment or codebase. Each project is associated with
 * a working directory where terminal sessions will be created.
 * 
 * Key Features:
 * - Unique identification for data persistence and UI tracking
 * - Association with a file system directory for session context
 * - Creation timestamp for project management and sorting
 * - Codable compliance for local storage and data serialization
 * 
 * Usage:
 * Projects are created by users through CreateProjectView and are used to:
 * - Group related terminal sessions by context
 * - Provide working directory context for new sessions
 * - Display session counts and activity status
 * - Organize development workflows
 */
struct Project: Identifiable, Codable {
    
    // MARK: - Properties
    
    /// Unique identifier for the project
    /// Generated automatically and used for SwiftUI list identification and data persistence
    let id = UUID()
    
    /// Human-readable name for the project
    /// Displayed in the UI and used for project identification by users
    var name: String
    
    /// File system path where terminal sessions for this project will be created
    /// Must be a valid directory path on the target system (VibeTunnel server)
    var workingDirectory: String
    
    /// Timestamp when the project was created
    /// Used for sorting projects and displaying creation information
    var createdAt: Date
    
    // MARK: - Initialization
    
    /**
     * Creates a new project with the specified name and working directory
     * 
     * The creation timestamp is automatically set to the current date/time.
     * The unique ID is generated automatically by the UUID() initializer.
     * 
     * Parameters:
     * - name: Display name for the project (e.g., "My Web App", "API Server")
     * - workingDirectory: File system path for terminal sessions (e.g., "/Users/dev/myproject")
     */
    init(name: String, workingDirectory: String) {
        self.name = name
        self.workingDirectory = workingDirectory
        self.createdAt = Date()
    }
}

// MARK: - Extensions

/**
 * Additional computed properties and methods for Project
 * 
 * These extensions provide convenient access to related data and functionality
 * without cluttering the main struct definition.
 */
extension Project {
    
    /**
     * Returns a formatted creation date string for display
     * 
     * Provides a user-friendly representation of when the project was created,
     * suitable for display in project lists or detail views.
     * 
     * Returns: Formatted date string (e.g., "Jun 16, 2025")
     */
    var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
    
    /**
     * Returns the last component of the working directory path
     * 
     * Useful for displaying a shortened version of the directory path
     * when full paths are too long for the UI.
     * 
     * Returns: Directory name (e.g., "myproject" from "/Users/dev/myproject")
     */
    var directoryName: String {
        return (workingDirectory as NSString).lastPathComponent
    }
}