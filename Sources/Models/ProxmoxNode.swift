import Foundation

struct ProxmoxNode: Identifiable, Codable, Hashable {
    var id: String {
        return node
    }
    let node: String
    let status: String
    
    let cpu: Double?
    let maxcpu: Double?
    let mem: Int64?
    let maxmem: Int64?
    let disk: Int64?
    let maxdisk: Int64?
    
    var isOnline: Bool { return status == "online" }
    
    var cpuUsage: Double {
        return cpu ?? 0.0
    }
    
    var cpuUsageFormatted: String {
        return String(format: "%.1f%%", cpuUsage * 100)
    }
    
    var memUsage: Double {
        guard let mem = mem, let maxmem = maxmem, maxmem > 0 else { return 0.0 }
        return Double(mem) / Double(maxmem)
    }
    
    var memUsageFormatted: String {
        guard let mem = mem, let maxmem = maxmem, maxmem > 0 else { return "-" }
        let percent = (Double(mem) / Double(maxmem)) * 100
        return String(format: "%.0f%%", percent)
    }
    
    var diskUsage: Double {
        guard let disk = disk, let maxdisk = maxdisk, maxdisk > 0 else { return 0.0 }
        return Double(disk) / Double(maxdisk)
    }
    
    var diskUsageFormatted: String {
        guard let disk = disk, let maxdisk = maxdisk, maxdisk > 0 else { return "-" }
        let percent = (Double(disk) / Double(maxdisk)) * 100
        return String(format: "%.0f%%", percent)
    }
}
