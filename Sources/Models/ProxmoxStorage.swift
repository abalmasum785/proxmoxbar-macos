import Foundation

struct ProxmoxStorage: Identifiable, Codable {
    var id: String {
        return "\(node)-\(storage)"
    }
    let storage: String
    let node: String
    let status: String
    
    let disk: Int64?
    let maxdisk: Int64?
    
    var isAvailable: Bool {
        return status == "available"
    }
}
