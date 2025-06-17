import SwiftUI
import UniformTypeIdentifiers

struct CreateProjectView: View {
    @StateObject private var dataStore = DataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var projectName = ""
    @State private var selectedDirectory = ""
    @State private var showingDirectoryPicker = false
    
    init() {
        // Set default directory to user's home directory
        _selectedDirectory = State(initialValue: NSHomeDirectory())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Working Directory")) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Enter directory path", text: $selectedDirectory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        HStack {
                            Button(action: {
                                showingDirectoryPicker = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "folder")
                                    Text("Browse...")
                                }
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                selectedDirectory = NSHomeDirectory()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "house")
                                    Text("Home")
                                }
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.gray)
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        
                        if !selectedDirectory.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Directory: \(selectedDirectory)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                
                Section {
                    Button(action: createProject) {
                        HStack {
                            Spacer()
                            Text("Create Project")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(projectName.isEmpty)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedDirectory = url.path
                }
            case .failure(let error):
                print("Directory selection failed: \(error)")
            }
        }
    }
    
    private func createProject() {
        let newProject = Project(name: projectName, workingDirectory: selectedDirectory)
        dataStore.addProject(newProject)
        dismiss()
    }
}

#Preview {
    CreateProjectView()
}