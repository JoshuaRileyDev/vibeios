//
//  vibeiosApp.swift
//  VibeIOS - Terminal Session Management for iOS
//
//  Main application entry point and configuration.
//  This file defines the root app structure and initializes the SwiftUI app lifecycle.
//
//  Created by Joshua Riley on 16/06/2025.
//

import SwiftUI

/**
 * Main application entry point for VibeIOS
 * 
 * The @main attribute marks this as the app's entry point. SwiftUI will automatically
 * create an instance of this struct and call its body property to build the app's
 * scene hierarchy.
 * 
 * Features:
 * - Single window group configuration suitable for iOS
 * - Loads ContentView as the root view
 * - Handles app lifecycle automatically through SwiftUI
 */
@main
struct vibeiosApp: App {
    
    /**
     * Defines the app's scene configuration
     * 
     * WindowGroup is the primary scene type for iOS apps. It automatically handles:
     * - Window management across different devices (iPhone, iPad)
     * - State restoration when the app is backgrounded/foregrounded
     * - Multi-window support on iPad (when needed)
     * 
     * Returns: A scene containing the app's root view hierarchy
     */
    var body: some Scene {
        WindowGroup {
            // ContentView serves as the navigation root for the entire app
            // It coordinates between the main projects list and settings
            ContentView()
        }
    }
}
