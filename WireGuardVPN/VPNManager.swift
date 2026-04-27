import NetworkExtension
import Combine

class VPNManager: ObservableObject {
    static let shared = VPNManager()

    @Published var status: NEVPNStatus = .disconnected
    @Published var isConnected = false
    @Published var isConnecting = false

    private var tunnelManager: NETunnelProviderManager?
    private let extensionBundleID = "com.riovpn.freevpn.WireGuardVPNExtension"
    private let configKey = "WireGuardConfig"

    var wireGuardConfig: String {
        get { UserDefaults.standard.string(forKey: configKey) ?? defaultConfig }
        set { UserDefaults.standard.set(newValue, forKey: configKey) }
    }

    private init() {
        loadManager()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusChanged(_:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }

    func loadManager() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tunnelManager = managers?.first {
                    ($0.protocolConfiguration as? NETunnelProviderProtocol)?
                        .providerBundleIdentifier == self.extensionBundleID
                }
                self.updateStatus(self.tunnelManager?.connection.status ?? .disconnected)
            }
        }
    }

    func connect() {
        let manager = tunnelManager ?? NETunnelProviderManager()

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = extensionBundleID
        proto.serverAddress = extractEndpoint(from: wireGuardConfig)
        proto.providerConfiguration = [configKey: wireGuardConfig]

        manager.localizedDescription = "WireGuard VPN"
        manager.protocolConfiguration = proto
        manager.isEnabled = true

        manager.saveToPreferences { [weak self] error in
            guard let self else { return }
            if let error {
                print("VPN save error: \(error.localizedDescription)")
                return
            }
            self.tunnelManager = manager
            manager.loadFromPreferences { error in
                if let error {
                    print("VPN reload error: \(error.localizedDescription)")
                    return
                }
                do {
                    try manager.connection.startVPNTunnel()
                } catch {
                    print("VPN start error: \(error.localizedDescription)")
                }
            }
        }
    }

    func disconnect() {
        tunnelManager?.connection.stopVPNTunnel()
    }

    func updateConfig(_ config: String) {
        wireGuardConfig = config
    }

    @objc private func vpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else { return }
        DispatchQueue.main.async { self.updateStatus(connection.status) }
    }

    private func updateStatus(_ newStatus: NEVPNStatus) {
        status = newStatus
        isConnected = newStatus == .connected
        isConnecting = newStatus == .connecting || newStatus == .reasserting
    }

    private func extractEndpoint(from config: String) -> String {
        for line in config.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.lowercased().hasPrefix("endpoint") else { continue }
            let value = trimmed.components(separatedBy: "=").dropFirst().joined(separator: "=")
                .trimmingCharacters(in: .whitespaces)
            if let idx = value.lastIndex(of: ":") {
                return String(value[value.startIndex..<idx])
            }
            return value
        }
        return "VPN Server"
    }

    private var defaultConfig: String {
        """
        [Interface]
        PrivateKey = <YOUR_PRIVATE_KEY>
        Address = 10.0.0.2/32
        DNS = 1.1.1.1

        [Peer]
        PublicKey = <SERVER_PUBLIC_KEY>
        AllowedIPs = 0.0.0.0/0
        Endpoint = vpn.example.com:51820
        PersistentKeepalive = 25
        """
    }
}
