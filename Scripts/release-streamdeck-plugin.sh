#!/bin/sh
# Assemble a clean Stream Deck plugin release and, optionally, a notarized CLI pkg.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT="$ROOT/StreamDeck-Shortcuts.xcodeproj"
SCHEME="StreamDeck-Shortcuts"
PLUGIN_UUID="com.sentinelite.streamdeckshortcuts"
DEFAULT_TEMPLATE="$HOME/Library/Application Support/com.elgato.StreamDeck/Plugins/$PLUGIN_UUID.sdPlugin"
DEFAULT_IDENTITY="Developer ID Application: FTRBND, LLC (9JJ9796LNX)"
DEFAULT_INSTALLER_IDENTITY="Developer ID Installer: FTRBND, LLC (9JJ9796LNX)"
OUTPUT="$ROOT/dist"
TEMPLATE="${STREAMDECK_PLUGIN_TEMPLATE:-$DEFAULT_TEMPLATE}"
SIGNING_IDENTITY="${DEVELOPER_ID_APPLICATION:-$DEFAULT_IDENTITY}"
INSTALLER_IDENTITY="${DEVELOPER_ID_INSTALLER:-$DEFAULT_INSTALLER_IDENTITY}"
NOTARY_PROFILE="${NOTARY_PROFILE:-Developer-altool}"
NOTARIZE_PKG=0
SKIP_BUILD=0
DRY_RUN=0

usage() {
    cat <<'EOF'
Usage: Scripts/release-streamdeck-plugin.sh [options]

Archives the Release executable, assembles a clean .sdPlugin bundle, signs its
executable, validates it, and writes a .streamDeckPlugin artifact.

The bundle template supplies the manifest, icons, and other Stream Deck assets.
By default it uses the locally installed plugin. For repeatable CI, pass a clean
template with --template (or set STREAMDECK_PLUGIN_TEMPLATE).

Options:
  --output PATH           Artifact directory (default: ./dist)
  --template PATH         Source .sdPlugin template
  --skip-build            Reuse STREAMDECK_ARCHIVE instead of creating one
  --notarize-pkg          Also build, submit, staple, and validate a CLI .pkg
  --dry-run               Print the release plan without changing anything
  -h, --help              Show this help

Environment:
  STREAMDECK_PLUGIN_TEMPLATE  Default template override
  STREAMDECK_ARCHIVE          Existing .xcarchive used with --skip-build
  DEVELOPER_ID_APPLICATION    Signing identity override
  DEVELOPER_ID_INSTALLER      Installer signing identity override
  NOTARY_PROFILE              notarytool keychain profile (default: Developer-altool)
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
        --output) OUTPUT=${2:?Missing output path}; shift 2 ;;
        --template) TEMPLATE=${2:?Missing template path}; shift 2 ;;
        --skip-build) SKIP_BUILD=1; shift ;;
        --notarize-pkg) NOTARIZE_PKG=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

VERSION=$(sed -nE 's/.*static var version: String = "([^"]+)".*/\1/p' "$ROOT/StreamDeck-Shortcuts/entry.swift")
PI_VERSION=$(sed -nE "s/^var RELEASE = '([^']+)';/\1/p" "$ROOT/PropertyInspectorViews/main_pi.js")
if [ -z "$VERSION" ] || [ "$VERSION" != "$PI_VERSION" ]; then
    echo "Version mismatch: Swift=$VERSION PropertyInspector=$PI_VERSION" >&2
    exit 1
fi

if [ "$DRY_RUN" -eq 0 ] && [ ! -d "$TEMPLATE" ]; then
    echo "Plugin template not found: $TEMPLATE" >&2
    echo "Install the plugin once, or pass --template /path/to/plugin.sdPlugin." >&2
    exit 1
fi

if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$OUTPUT"
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/streamdeck-shortcuts-release.XXXXXX")
trap 'rm -rf "$WORK"' EXIT HUP INT TERM
ARCHIVE="${STREAMDECK_ARCHIVE:-$WORK/StreamDeck-Shortcuts.xcarchive}"
STAGED_BUNDLE="$WORK/$PLUGIN_UUID.sdPlugin"

if [ "$SKIP_BUILD" -eq 0 ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
        run xcodebuild archive \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration Release \
            -destination generic/platform=macOS \
            -archivePath "$ARCHIVE" \
            CODE_SIGNING_ALLOWED=NO
    else
        BUILD_LOG="$WORK/xcodebuild-archive.log"
        echo "Archiving Release configuration…"
        if ! xcodebuild archive \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration Release \
            -destination generic/platform=macOS \
            -archivePath "$ARCHIVE" \
            CODE_SIGNING_ALLOWED=NO >"$BUILD_LOG" 2>&1; then
            tail -n 100 "$BUILD_LOG" >&2
            exit 1
        fi
        tail -n 3 "$BUILD_LOG"
    fi
fi

EXECUTABLE="$ARCHIVE/Products/usr/local/bin/StreamDeck-Shortcuts"
if [ "$DRY_RUN" -eq 0 ] && [ ! -f "$EXECUTABLE" ]; then
    echo "Archived executable not found: $EXECUTABLE" >&2
    echo "If reusing an archive, pass --skip-build with STREAMDECK_ARCHIVE set." >&2
    exit 1
fi

echo "Assembling Stream Deck Shortcuts $VERSION"
run rsync -a --delete \
    --exclude '.DS_Store' \
    --exclude 'userSettings.json' \
    --exclude 'Preview/' \
    --exclude '*.local.js' \
    "$TEMPLATE/" "$STAGED_BUNDLE/"
run rsync -a --delete \
    --exclude '.DS_Store' \
    --exclude 'Preview/' \
    --exclude '*.local.js' \
    "$ROOT/PropertyInspectorViews/" "$STAGED_BUNDLE/pi/"
run cp "$EXECUTABLE" "$STAGED_BUNDLE/StreamDeck-Shortcuts"
run chmod 755 "$STAGED_BUNDLE/StreamDeck-Shortcuts"
run plutil -replace Version -string "$VERSION" "$STAGED_BUNDLE/manifest.json"
run codesign --force --sign "$SIGNING_IDENTITY" --timestamp --options runtime "$STAGED_BUNDLE/StreamDeck-Shortcuts"
run codesign --verify --strict --verbose=4 "$STAGED_BUNDLE/StreamDeck-Shortcuts"
run "$ROOT/Scripts/verify-streamdeck-plugin-bundle.sh" "$STAGED_BUNDLE"
run streamdeck validate --no-update-check "$STAGED_BUNDLE"
run streamdeck pack --force --no-update-check --output "$OUTPUT" "$STAGED_BUNDLE"

if [ "$NOTARIZE_PKG" -eq 1 ]; then
    PRODUCTS="$WORK/Products"
    PKG="$OUTPUT/StreamDeck-Shortcuts-$VERSION.pkg"
    run mkdir -p "$PRODUCTS/usr/local/bin"
    run cp "$STAGED_BUNDLE/StreamDeck-Shortcuts" "$PRODUCTS/usr/local/bin/StreamDeck-Shortcuts"
    run pkgbuild \
        --root "$PRODUCTS" \
        --identifier "com.sentinelite.streamdeck-shortcuts" \
        --version "$VERSION" \
        --install-location / \
        --sign "$INSTALLER_IDENTITY" \
        "$PKG"
    run xcrun notarytool submit "$PKG" --keychain-profile "$NOTARY_PROFILE" --wait
    run xcrun stapler staple "$PKG"
    run xcrun stapler validate "$PKG"
    run spctl -a -vv -t install "$PKG"
fi

echo "Release artifacts written to: $OUTPUT"
