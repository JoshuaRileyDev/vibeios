import SwiftUI
import UniformTypeIdentifiers

struct CreateProjectView: View {
    @StateObject private var dataStore = DataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var projectName = ""
    @State private var selectedDirectory = ""
    @State private var showingDirectoryPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Working Directory")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingDirectoryPicker = true
                        }) {
                            HStack {
                                Image(systemName: "folder")
                                Text(selectedDirectory.isEmpty ? "Choose Directory" : "Change Directory")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        if !selectedDirectory.isEmpty {
                            Text(selectedDirectory)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                    .disabled(projectName.isEmpty || selectedDirectory.isEmpty)
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