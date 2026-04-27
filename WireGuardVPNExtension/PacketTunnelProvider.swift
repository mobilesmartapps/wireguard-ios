import NetworkExtension
import WireGuardKit
import os.log

private let log = Logger(subsystem: "com.example.WireGuardVPN.extension", category: "PacketTunnel")

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var adapter: WireGuardAdapter?

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard
            let proto = protocolConfiguration as? NETunnelProviderProtocol,
            let wgConfig = proto.providerConfiguration?["WireGuardConfig"] as? String
        else {
            completionHandler(ProviderError.missingConfiguration)
            return
        }

        let tunnelConfiguration: TunnelConfiguration
        do {
            tunnelConfiguration = try TunnelConfiguration(fromWgQuickConfig: wgConfig, called: "wg0")
        } catch {
            log.error("Failed to parse WireGuard config: \(error.localizedDescription)")
            completionHandler(error)
            return
        }

        let adapter = WireGuardAdapter(with: self) { level, message in
            switch level {
            case .verbose: log.debug("\(message)")
            case .error:   log.error("\(message)")
            @unknown default: log.log("\(message)")
            }
        }
        self.adapter = adapter

        adapter.start(tunnelConfiguration: tunnelConfiguration) { error in
            if let error { log.error("Adapter start failed: \(error.localizedDescription)") }
            completionHandler(error)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        adapter?.stop { error in
            if let error { log.error("Adapter stop error: \(error.localizedDescription)") }
            completionHandler()
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        completionHandler?(nil)
    }
}

enum ProviderError: LocalizedError {
    case missingConfiguration
    var errorDescription: String? { "WireGuard configuration is missing or invalid." }
}
