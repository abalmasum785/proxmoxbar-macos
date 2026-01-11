import SwiftUI

struct AddServerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: SettingsService
    
    @State private var name: String = ""
    @State private var url: String = "https://"
    @State private var tokenId: String = ""
    @State private var secret: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Proxmox Node")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("My Server", text: $name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Server URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("https://192.168.1.10:8006", text: $url)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Token ID")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("user@pam!tokenid", text: $tokenId)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Secret")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SecureField("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", text: $secret)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Server") {
                    addServer()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || url.isEmpty || tokenId.isEmpty || secret.isEmpty)
            }
        }
        .padding()
        .frame(width: 320)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active))
        .presentationBackground(.clear)
    }
    
    private func addServer() {
        let newServer = ProxmoxServerConfig(
            name: name,
            url: url,
            tokenId: tokenId,
            secret: secret
        )
        settings.addServer(newServer)
        dismiss()
    }
}
