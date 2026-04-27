#!/bin/sh
# Builds libwg-go.a for iOS (arm64). Run once before opening in Xcode,
# and again whenever the WireGuardKitGo Go sources change.
set -e

SDK=$(DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer /usr/bin/xcrun --sdk iphoneos --show-sdk-path)
GODIR="$(dirname "$0")/Packages/WireGuardKit/Sources/WireGuardKitGo"
OUTDIR="$(dirname "$0")/GoLib"

mkdir -p "$OUTDIR"

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
PLATFORM_NAME=iphoneos \
ARCHS=arm64 \
SDKROOT="$SDK" \
IPHONEOS_DEPLOYMENT_TARGET=16.0 \
DEPLOYMENT_TARGET_CLANG_FLAG_NAME=miphoneos-version-min \
DEPLOYMENT_TARGET_CLANG_ENV_NAME=IPHONEOS_DEPLOYMENT_TARGET \
CONFIGURATION_BUILD_DIR="$OUTDIR" \
CONFIGURATION_TEMP_DIR="$OUTDIR/.tmp" \
make -C "$GODIR" build

echo "libwg-go.a built at $OUTDIR/libwg-go.a"
