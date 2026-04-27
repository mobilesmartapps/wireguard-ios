import SwiftUI

struct ConfigView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @Environment(\.dismiss) private var dismiss
    @State private var configText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Paste a wg-quick format configuration ([Interface] + [Peer] sections).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                TextEditor(text: $configText)
                    .font(.system(.footnote, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)

                if !configText.isEmpty && !isValidConfig {
                    Label("Missing [Interface] or [Peer] section.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .navigationTitle("WireGuard Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        vpnManager.updateConfig(configText)
                        dismiss()
                    }
                    .disabled(configText.isEmpty || !isValidConfig)
                    .fontWeight(.semibold)
                }
            }
            .onAppear { configText = vpnManager.wireGuardConfig }
        }
    }

    private var isValidConfig: Bool {
        let lower = configText.lowercased()
        return lower.contains("[interface]") && lower.contains("[peer]")
    }
}
