import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsService
    @ObservedObject var launchService: LaunchAtLoginService
    var onBack: () -> Void
    
    @State private var showAddServer = false
    @State private var serverToDelete: ProxmoxServerConfig?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Text("Settings")
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GENERAL")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                                Text("Launch at Login")
                                    .font(.system(size: 13))
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { launchService.isEnabled },
                                    set: { _ in launchService.toggle() }
                                ))
                                .labelsHidden()
                                .toggleStyle(.switch)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(8)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SERVERS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showAddServer = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 4)
                        
                        if settings.servers.isEmpty {
                            Text("No servers configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(settings.servers) { server in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(server.name)
                                                .font(.system(size: 13, weight: .medium))
                                            Text(server.url)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        
                                        Button {
                                            serverToDelete = server
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(10)
                                    .background(Color.primary.opacity(0.03))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                }
                .padding(20)
            }
        }
        .background(CursorFixView())
        .sheet(isPresented: $showAddServer) {
            AddServerView(settings: settings)
        }
        .alert(item: $serverToDelete) { server in
            Alert(
                title: Text("Delete Server"),
                message: Text("Are you sure you want to remove '\(server.name)'?"),
                primaryButton: .destructive(Text("Delete")) {
                    settings.removeServer(id: server.id)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
