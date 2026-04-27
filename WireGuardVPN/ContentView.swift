import SwiftUI
import NetworkExtension

struct ContentView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var showConfig = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                VStack(spacing: 0) {
                    Spacer()
                    statusIcon
                        .padding(.bottom, 24)
                    statusLabel
                        .padding(.bottom, 64)
                    connectButton
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("WireGuard VPN")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showConfig = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showConfig) {
                ConfigView()
                    .environmentObject(vpnManager)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: vpnManager.isConnected
                ? [Color(uiColor: .systemBackground), Color.green.opacity(0.12)]
                : [Color(uiColor: .systemBackground), Color.blue.opacity(0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: 140, height: 140)
            Image(systemName: vpnManager.isConnected ? "lock.shield.fill" : "shield.slash.fill")
                .font(.system(size: 64))
                .foregroundStyle(accentColor)
                .symbolRenderingMode(.multicolor)
        }
    }

    private var statusLabel: some View {
        VStack(spacing: 6) {
            Text(statusTitle)
                .font(.title2.bold())
                .foregroundStyle(accentColor)
            Text(statusSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var connectButton: some View {
        Button(action: toggleVPN) {
            Text(vpnManager.isConnected ? "Disconnect" : "Connect")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(buttonColor)
                )
                .foregroundStyle(.white)
        }
        .disabled(vpnManager.isConnecting)
        .animation(.easeInOut(duration: 0.25), value: vpnManager.status)
    }

    private var accentColor: Color {
        switch vpnManager.status {
        case .connected:    return .green
        case .connecting, .reasserting: return .orange
        default:            return .blue
        }
    }

    private var buttonColor: Color {
        vpnManager.isConnected ? .red : (vpnManager.isConnecting ? .orange : .blue)
    }

    private var statusTitle: String {
        switch vpnManager.status {
        case .connected:      return "Connected"
        case .connecting:     return "Connecting…"
        case .disconnecting:  return "Disconnecting…"
        case .reasserting:    return "Reconnecting…"
        default:              return "Not Connected"
        }
    }

    private var statusSubtitle: String {
        vpnManager.isConnected
            ? "Your connection is protected"
            : "Tap Connect to enable the VPN"
    }

    private func toggleVPN() {
        if vpnManager.isConnected || vpnManager.isConnecting {
            vpnManager.disconnect()
        } else {
            vpnManager.connect()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(VPNManager.shared)
}
