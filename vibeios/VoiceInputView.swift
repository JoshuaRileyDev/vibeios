import SwiftUI
import AVFoundation

struct VoiceInputView: View {
    @StateObject private var speechManager = SpeechRecognitionManager()
    @State private var showingPermissionAlert = false
    let onCommandReceived: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Voice input button
                Button(action: {
                    if speechManager.canRecord {
                        if speechManager.isListening {
                            speechManager.stopListening()
                            if !speechManager.recognizedText.isEmpty {
                                onCommandReceived(speechManager.recognizedText)
                                speechManager.clearText()
                            }
                        } else {
                            speechManager.startListening()
                        }
                    } else {
                        showingPermissionAlert = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: speechManager.isListening ? "mic.fill" : "mic")
                            .foregroundColor(speechManager.isListening ? .red : .blue)
                            .font(.title2)
                        
                        Text(speechManager.isListening ? "Stop Recording" : "Voice Input")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(speechManager.isListening ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(speechManager.isListening ? Color.red : Color.blue, lineWidth: 2)
                            )
                    )
                }
                .disabled(!speechManager.canRecord && speechManager.authorizationStatus != .notDetermined)
                
                Spacer()
                
                // Clear button (only show when there's recognized text)
                if !speechManager.recognizedText.isEmpty {
                    Button("Clear") {
                        speechManager.clearText()
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
                }
            }
            
            // Display recognized text
            if !speechManager.recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recognized Speech:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if speechManager.isListening {
                            HStack(spacing: 4) {
                                Text("Listening...")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                // Animated dots
                                HStack(spacing: 2) {
                                    ForEach(0..<3) { index in
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 4, height: 4)
                                            .scaleEffect(speechManager.isListening ? 1.0 : 0.5)
                                            .animation(
                                                Animation.easeInOut(duration: 0.6)
                                                    .repeatForever()
                                                    .delay(Double(index) * 0.2),
                                                value: speechManager.isListening
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    Text(speechManager.recognizedText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                    
                    // Send button
                    Button(action: {
                        onCommandReceived(speechManager.recognizedText)
                        speechManager.clearText()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Command")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(speechManager.recognizedText.isEmpty)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Status indicators
            HStack {
                statusIndicator(
                    icon: "mic",
                    text: microphoneStatusText,
                    color: microphoneStatusColor
                )
                
                Spacer()
                
                statusIndicator(
                    icon: "brain",
                    text: speechRecognitionStatusText,
                    color: speechRecognitionStatusColor
                )
            }
            .font(.caption2)
        }
        .padding()
        .background(Color(.systemBackground))
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Voice input requires microphone and speech recognition permissions. Please enable them in Settings.")
        }
    }
    
    private var microphoneStatusText: String {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return "Microphone OK"
        case .denied:
            return "Microphone Denied"
        case .undetermined:
            return "Microphone Pending"
        @unknown default:
            return "Microphone Unknown"
        }
    }
    
    private var microphoneStatusColor: Color {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return .green
        case .denied:
            return .red
        case .undetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private var speechRecognitionStatusText: String {
        switch speechManager.authorizationStatus {
        case .authorized:
            return speechManager.isAvailable ? "Speech OK" : "Speech Unavailable"
        case .denied:
            return "Speech Denied"
        case .restricted:
            return "Speech Restricted"
        case .notDetermined:
            return "Speech Pending"
        @unknown default:
            return "Speech Unknown"
        }
    }
    
    private var speechRecognitionStatusColor: Color {
        switch speechManager.authorizationStatus {
        case .authorized:
            return speechManager.isAvailable ? .green : .orange
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private func statusIndicator(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(color)
        }
    }
}

#Preview {
    VoiceInputView { command in
        print("Received command: \(command)")
    }
    .padding()
}