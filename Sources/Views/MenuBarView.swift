import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: ProxmoxViewModel
    @ObservedObject var settings: SettingsService
    @ObservedObject var launchService: LaunchAtLoginService
    @ObservedObject var updaterController: UpdaterController
    
    @Environment(\.colorScheme) var colorScheme
    
    enum Screen {
        case dashboard
        case settings
    }
    
    @State private var currentScreen: Screen = .dashboard
    
    private var statusColor: Color {
        switch viewModel.appState {
        case .running: return .green
        case .stopped: return .gray
        case .loading: return .orange
        case .error: return .red
        }
    }
    
    private var statusText: String {
        switch viewModel.appState {
        case .running: return "CONNECTED"
        case .stopped: return "DISCONNECTED"
        case .loading(let text): return text
        case .error: return "ERROR"
        }
    }
    
    private var headerIcon: NSImage {
        return NSImage(systemSymbolName: "server.rack", accessibilityDescription: nil) ?? NSImage()
    }
    
    var body: some View {
        ZStack {
            if currentScreen == .dashboard {
                dashboardContent
                    .transition(.move(edge: .leading))
            } else {
                SettingsView(settings: settings, launchService: launchService, updaterController: updaterController) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentScreen = .dashboard
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentScreen)
        .background(WindowAccessor { window in
            guard let window = window else { return }
            if window.styleMask.contains(.resizable) {
                window.styleMask.remove(.resizable)
            }
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.backgroundColor = .clear
            window.isOpaque = false
        })
        .background(CursorFixView())
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active))
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    var dashboardContent: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 12) {
                HStack {
                    Image(nsImage: headerIcon)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Menu {
                            ForEach(settings.servers) { server in
                                Button {
                                    viewModel.selectedServerId = server.id
                                    Task { await viewModel.loadData() }
                                } label: {
                                    if viewModel.selectedServerId == server.id {
                                        Label(server.name, systemImage: "checkmark")
                                    } else {
                                        Text(server.name)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.selectedServerId == nil ? "All Servers" : (settings.servers.first(where: { $0.id == viewModel.selectedServerId })?.name ?? "Unknown"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .contentShape(Rectangle())
                        }
                        .menuStyle(.borderlessButton)
                        .fixedSize()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                            Text(statusText)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentScreen = .settings
                            }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Divider()
                        
                        Button {
                            NSApplication.shared.terminate(nil)
                        } label: {
                            Label("Quit Proxmox Bar", systemImage: "power")
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                if case .loading(let text) = viewModel.appState {
                     HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text(text.capitalized)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 30)
                } else if let errorMsg = viewModel.errorMessage {
                    HStack(spacing: 8) {
                         Image(systemName: "exclamationmark.triangle.fill")
                             .foregroundColor(.red)
                         Text(errorMsg)
                             .font(.system(size: 11, weight: .medium))
                             .foregroundColor(.red)
                             .lineLimit(1)
                     }
                     .frame(height: 30)
                } else {
                    HStack(spacing: 10) {
                        ActionStatusButton(icon: "arrow.triangle.2.circlepath", label: "Refresh") {
                            Task.detached { await viewModel.loadData() }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .background(.thinMaterial)
            
            Divider()
            
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search resources...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                    
                    Menu {
                        ForEach(ProxmoxViewModel.ResourceFilter.allCases, id: \.self) { filter in
                            Button {
                                viewModel.resourceFilter = filter
                            } label: {
                                if viewModel.resourceFilter == filter {
                                    Label(filter.rawValue, systemImage: filter.icon)
                                } else {
                                    Label(filter.rawValue, systemImage: filter.icon)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Text(viewModel.resourceFilter.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 6)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                }
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if viewModel.filteredVMs.isEmpty {
                        Text("No VMs found")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                        if !settings.isValid {
                             Button("Open Settings") {
                                 withAnimation { currentScreen = .settings }
                             }
                             .padding()
                        }
                    } else {
                        HStack {
                            Text("\(viewModel.filteredVMs.count) \(viewModel.filteredVMs.count == 1 ? "RESOURCE" : "RESOURCES")")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        ForEach(viewModel.filteredVMs) { vm in
                            VMRow(vm: vm, viewModel: viewModel)
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
    }
}

struct ActionStatusButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(isHovered ? Color.white.opacity(0.1) : Color.clear)
            .background(.regularMaterial)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

struct VMRow: View {
    let vm: ProxmoxVM
    @ObservedObject var viewModel: ProxmoxViewModel
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(vm.isRunning ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 28, height: 28)
                
                Image(systemName: vm.type == "lxc" ? "cube.box" : "display")
                    .font(.system(size: 12))
                    .foregroundColor(vm.isRunning ? .green : .gray)
                    .frame(width: 14)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    Text("\(vm.vmid)")
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(4)
                    
                    Text(vm.status.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(vm.isRunning ? .green : .secondary)

                    if vm.isRunning {
                        let cpuVal = vm.cpu ?? 0
                        let memVal = (vm.maxmem ?? 0) > 0 ? Double(vm.mem ?? 0) / Double(vm.maxmem!) : 0
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Image(systemName: "cpu")
                            .font(.system(size: 10))
                            .foregroundColor(getUsageColor(cpuVal))
                        Text(vm.cpuUsage)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(getUsageColor(cpuVal))
                        
                        Image(systemName: "memorychip")
                            .font(.system(size: 10))
                            .foregroundColor(getUsageColor(memVal))
                            .padding(.leading, 4)
                        Text(vm.memUsage)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(getUsageColor(memVal))
                        
                        if vm.type != "qemu", let maxdisk = vm.maxdisk, maxdisk > 0 {
                            let diskVal = Double(vm.disk ?? 0) / Double(maxdisk)
                            
                            Image(systemName: "internaldrive")
                                .font(.system(size: 10))
                                .foregroundColor(getUsageColor(diskVal))
                                .padding(.leading, 4)
                            Text(vm.diskUsage)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(getUsageColor(diskVal))
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.toggleVMState(vm)
                }
            } label: {
                Image(systemName: vm.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 10))
                    .foregroundColor(vm.isRunning ? .red : .green)
                    .frame(width: 20, height: 20)
                    .background(Color.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help(vm.isRunning ? "Stop (Shutdown)" : "Start")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
    
    private func getUsageColor(_ value: Double) -> Color {
        if value >= 0.95 {
            return .red
        } else if value >= 0.8 {
            return .orange
        } else {
            return .white.opacity(0.7)
        }
    }
}
