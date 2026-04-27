import SwiftUI

@main
struct WireGuardVPNApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(VPNManager.shared)
        }
    }
}
