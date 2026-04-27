# WireGuard VPN — iOS

A WireGuard VPN app for iOS built with SwiftUI and the official WireGuardKit library.

## Features

- Connect / Disconnect button with live status indicator
- Paste any standard `wg-quick` configuration (⚙️ gear icon)
- Network Extension (Packet Tunnel Provider) powered by WireGuardKit
- Supports iOS 16+

## Getting Started

### 1. Build the Go crypto backend

Once you clone the repo, run this **once** before opening Xcode:

```bash
./build-go.sh
```

This compiles `libwg-go.a` — the WireGuard Go crypto backend required by the Network Extension. You only need to re-run it if the Go sources in `Packages/WireGuardKit/Sources/WireGuardKitGo/` change.

> **Requirements:** Go (`brew install go`) and Xcode must be installed.

### 2. Open in Xcode

```bash
open WireGuardVPN.xcodeproj
```

### 3. Sign the app

- Go to **Xcode → Settings → Accounts** and sign in with your Apple ID
- Select the `WireGuardVPN` target → **Signing & Capabilities** → set your Team
- Do the same for the `WireGuardVPNExtension` target

### 4. Apple Developer Portal setup

Make sure the following exist in [developer.apple.com](https://developer.apple.com):

| Type | Identifier |
|---|---|
| App ID | `com.riovpn.freevpn` (Network Extensions + App Groups) |
| App ID | `com.riovpn.freevpn.WireGuardVPNExtension` (Network Extensions + App Groups) |
| App Group | `group.com.riovpn.freevpn` |

### 5. Add your WireGuard config

Launch the app → tap ⚙️ → paste your `wg-quick` format config → **Save** → **Connect**.

## Project Structure

```
WireGuardVPN/                   # Main app (SwiftUI)
│   App.swift
│   ContentView.swift           # Connect/Disconnect UI
│   VPNManager.swift            # NETunnelProviderManager wrapper
│   ConfigView.swift            # Config paste sheet
│
WireGuardVPNExtension/          # Network Extension
│   PacketTunnelProvider.swift  # NEPacketTunnelProvider + WireGuardAdapter
│   TunnelConfiguration+WgQuickConfig.swift
│
Packages/WireGuardKit/          # Vendored WireGuardKit (fixed for Xcode 26)
GoLib/                          # libwg-go.a output (git-ignored, built by build-go.sh)
build-go.sh                     # Builds the Go crypto backend
project.yml                     # xcodegen spec (regenerate .xcodeproj with `xcodegen generate`)
```

## License

WireGuardKit is © WireGuard LLC, licensed under MIT.
