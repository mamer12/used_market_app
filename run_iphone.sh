#!/bin/bash
# ─────────────────────────────────────────────────────────────
# run_iphone.sh — Build and run Luqta app on a physical iPhone
# App: Mustamal (com.mustafa.mustamal)
# Repo: ~/Documents/Development/Luqta/used_market_app
# ─────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "── Step 1: Getting Flutter dependencies ──────────────────"
flutter pub get

echo ""
echo "── Step 2: Detecting connected iOS devices ───────────────"
flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
devices = json.load(sys.stdin)
ios = [d for d in devices if d.get('targetPlatform','').startswith('ios') and not d.get('emulator', True)]
if not ios:
    print('No physical iPhone detected.')
    print('→ Connect your iPhone via USB and tap Trust on the device.')
    raise SystemExit(1)
for d in ios:
    print(f\"  Found: {d['name']} [{d['id']}] — iOS {d.get('sdk','?')}\")
" 2>/dev/null || flutter devices

echo ""
echo "── Step 3: Picking device ────────────────────────────────"
# Get first physical iOS device ID
DEVICE_ID=$(flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
devices = json.load(sys.stdin)
ios = [d for d in devices if d.get('targetPlatform','').startswith('ios') and not d.get('emulator', True)]
if ios:
    print(ios[0]['id'])
" 2>/dev/null)

if [ -z "$DEVICE_ID" ]; then
    echo "ERROR: No physical iPhone found. Check USB connection and trust prompt."
    echo "Run 'flutter devices' to see all available devices."
    exit 1
fi

echo "Using device: $DEVICE_ID"

echo ""
echo "── Step 4: Running app on iPhone ─────────────────────────"
echo "Tip: Make sure your iPhone and Mac are on the same WiFi"
echo "     and update the API base URL to your Mac's LAN IP."
echo ""

flutter run -d "$DEVICE_ID" "$@"
