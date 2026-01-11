import Foundation
import Combine

struct ProxmoxServerConfig: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var url: String
    var tokenId: String
    var secret: String
    
    var authHeader: String {
        return "PVEAPIToken=\(tokenId)=\(secret)"
    }
}

class SettingsService: ObservableObject {
    @Published var servers: [ProxmoxServerConfig] {
        didSet { saveServers() }
    }
    
    init() {
        self.servers = []
        loadServers()
        migrateLegacySettings()
    }
    
    private func loadServers() {
        if let data = UserDefaults.standard.data(forKey: "proxmox_servers"),
           let decoded = try? JSONDecoder().decode([ProxmoxServerConfig].self, from: data) {
            self.servers = decoded
        }
    }
    
    private func saveServers() {
        if let encoded = try? JSONEncoder().encode(servers) {
            UserDefaults.standard.set(encoded, forKey: "proxmox_servers")
        }
    }
    
    private func migrateLegacySettings() {
        if servers.isEmpty {
            let legacyUrl = UserDefaults.standard.string(forKey: "proxmox_url")
            let legacyToken = UserDefaults.standard.string(forKey: "proxmox_token_id")
            let legacySecret = UserDefaults.standard.string(forKey: "proxmox_secret")
            
            if let url = legacyUrl, !url.isEmpty,
               let token = legacyToken, !token.isEmpty,
               let secret = legacySecret, !secret.isEmpty {
                
                let legacyServer = ProxmoxServerConfig(
                    name: "Default Server",
                    url: url,
                    tokenId: token,
                    secret: secret
                )
                
                self.servers.append(legacyServer)
            }
        }
    }
    
    func addServer(_ server: ProxmoxServerConfig) {
        servers.append(server)
    }
    
    func removeServer(at offsets: IndexSet) {
        servers.remove(atOffsets: offsets)
    }
    
    func removeServer(id: UUID) {
        if let index = servers.firstIndex(where: { $0.id == id }) {
            servers.remove(at: index)
        }
    }
    
    var isEmpty: Bool {
        return servers.isEmpty
    }
    
    var isValid: Bool {
        return !servers.isEmpty
    }
}
