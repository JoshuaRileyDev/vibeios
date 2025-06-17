//
//  ContentView.swift
//  VibeIOS - Terminal Session Management for iOS
//
//  Root view controller that serves as the main navigation entry point.
//  Currently displays the projects list as the primary interface.
//
//  Created by Joshua Riley on 16/06/2025.
//

import SwiftUI

/**
 * Root content view for the VibeIOS application
 * 
 * This view serves as the primary navigation controller and content coordinator.
 * It's intentionally minimal to allow for future navigation enhancements such as:
 * - Tab bar navigation between different sections
 * - Side menu for additional features
 * - Onboarding flows for new users
 * 
 * Currently, it directly displays ProjectsListView, which contains its own
 * navigation structure and handles all project management functionality.
 */
struct ContentView: View {
    
    /**
     * Main view body that defines the app's primary interface
     * 
     * Currently shows ProjectsListView as the root, which includes:
     * - Project list with session counts
     * - Navigation to project details
     * - Settings access via toolbar
     * - Session creation and management
     * 
     * Returns: The main application view hierarchy
     */
    var body: some View {
        // ProjectsListView handles all main functionality and navigation
        // It includes its own NavigationView and toolbar configuration
        ProjectsListView()
    }
}

/**
 * SwiftUI preview for development and design iteration
 * 
 * This preview allows developers to see the ContentView in Xcode's preview canvas
 * without running the full app. It's useful for rapid UI development and testing.
 */
#Preview {
    ContentView()
}
