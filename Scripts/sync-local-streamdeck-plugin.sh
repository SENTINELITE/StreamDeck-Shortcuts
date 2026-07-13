#!/bin/sh
# Build the plugin and refresh the locally installed Stream Deck bundle.
#
# This is for development only. It never creates a distributable artifact.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT="$ROOT/StreamDeck-Shortcuts.xcodeproj"
SCHEME="StreamDeck-Shortcuts"
PLUGIN_UUID="com.sentinelite.streamdeckshortcuts"
DEFAULT_BUNDLE="$HOME/Library/Application Support/com.elgato.StreamDeck/Plugins/$PLUGIN_UUID.sdPlugin"
CONFIGURATION=Debug
DERIVED_DATA="$ROOT/DerivedData/StreamDeck-Shortcuts-local"
BUNDLE="$DEFAULT_BUNDLE"
BUILD=1
RESTART=0
DRY_RUN=0

usage() {
    cat <<'EOF'
Usage: Scripts/sync-local-streamdeck-plugin.sh [options]

Builds the Swift plugin, copies the fresh executable and Property Inspector into
the locally installed Stream Deck bundle, and validates that exact bundle.

Options:
  --configuration NAME    Xcode configuration to build (default: Debug)
  --derived-data PATH     DerivedData location (default: repo DerivedData)
  --bundle PATH           Installed .sdPlugin to refresh
  --no-build              Reuse an existing executable in DerivedData
  --restart               Restart this plugin in Stream Deck after syncing
  --dry-run               Print the planned work without changing anything
  -h, --help              Show this help
EOF
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '+ '
        printf '%s ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --configuration) CONFIGURATION=${2:?Missing configuration}; shift 2 ;;
        --derived-data) DERIVED_DATA=${2:?Missing DerivedData path}; shift 2 ;;
        --bundle) BUNDLE=${2:?Missing bundle path}; shift 2 ;;
        --no-build) BUILD=0; shift ;;
        --restart) RESTART=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

VERSION=$(sed -nE 's/.*static var version: String = "([^"]+)".*/\1/p' "$ROOT/StreamDeck-Shortcuts/entry.swift")
if [ -z "$VERSION" ]; then
    echo "Could not read the plugin version from StreamDeck-Shortcuts/entry.swift." >&2
    exit 1
fi

EXECUTABLE="$DERIVED_DATA/Build/Products/$CONFIGURATION/StreamDeck-Shortcuts"

if [ "$BUILD" -eq 1 ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
        run xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration "$CONFIGURATION" \
            -destination platform=macOS \
            -derivedDataPath "$DERIVED_DATA" \
            CODE_SIGNING_ALLOWED=NO \
            build
    else
        mkdir -p "$DERIVED_DATA"
        BUILD_LOG="$DERIVED_DATA/streamdeck-shortcuts-build.log"
        echo "Building $CONFIGURATION configuration…"
        if ! xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration "$CONFIGURATION" \
            -destination platform=macOS \
            -derivedDataPath "$DERIVED_DATA" \
            CODE_SIGNING_ALLOWED=NO \
            build >"$BUILD_LOG" 2>&1; then
            tail -n 80 "$BUILD_LOG" >&2
            exit 1
        fi
        tail -n 3 "$BUILD_LOG"
    fi
fi

if [ "$DRY_RUN" -eq 0 ] && [ ! -f "$EXECUTABLE" ]; then
    echo "Built executable not found: $EXECUTABLE" >&2
    echo "Run without --no-build, or supply the matching --derived-data path." >&2
    exit 1
fi

if [ "$DRY_RUN" -eq 0 ] && [ ! -d "$BUNDLE" ]; then
    echo "Installed plugin bundle not found: $BUNDLE" >&2
    echo "Install the plugin once in Stream Deck, or pass --bundle /path/to/plugin.sdPlugin." >&2
    exit 1
fi

echo "Syncing Stream Deck Shortcuts $VERSION to: $BUNDLE"
run cp "$EXECUTABLE" "$BUNDLE/StreamDeck-Shortcuts"
run chmod 755 "$BUNDLE/StreamDeck-Shortcuts"
run rsync -a --delete \
    --exclude '.DS_Store' \
    --exclude 'Preview/' \
    --exclude '*.local.js' \
    "$ROOT/PropertyInspectorViews/" "$BUNDLE/pi/"
run plutil -replace Version -string "$VERSION" "$BUNDLE/manifest.json"
run "$ROOT/Scripts/verify-streamdeck-plugin-bundle.sh" "$BUNDLE"
run streamdeck validate --no-update-check "$BUNDLE"

if [ "$RESTART" -eq 1 ]; then
    run streamdeck restart "$PLUGIN_UUID"
else
    echo "Synced. Restart the plugin from Stream Deck, or rerun with --restart."
fi
