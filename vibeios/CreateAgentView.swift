import SwiftUI

struct CreateAgentView: View {
    let projectId: UUID
    @StateObject private var dataStore = DataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var agentName = ""
    @State private var agentDescription = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Agent Details")) {
                    TextField("Agent Name", text: $agentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $agentDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: createAgent) {
                        HStack {
                            Spacer()
                            Text("Create Agent")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(agentName.isEmpty || agentDescription.isEmpty)
                }
            }
            .navigationTitle("New Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createAgent() {
        let newAgent = Agent(name: agentName, description: agentDescription)
        dataStore.addAgent(to: projectId, agent: newAgent)
        dismiss()
    }
}

#Preview {
    CreateAgentView(projectId: UUID())
}