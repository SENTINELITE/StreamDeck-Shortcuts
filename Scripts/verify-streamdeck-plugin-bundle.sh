#!/bin/sh
set -eu

bundle_path=${1:?Usage: sh Scripts/verify-streamdeck-plugin-bundle.sh /path/to/plugin.sdPlugin}

if [ ! -d "$bundle_path" ]; then
  echo "Plugin bundle not found: $bundle_path" >&2
  exit 2
fi

preview_asset=$(find "$bundle_path" \( -path '*/Preview/*' -o -iname '*preview*.html' -o -iname '*preview*.js' \) -print -quit)
if [ -n "$preview_asset" ]; then
  echo "Preview asset must not ship: $preview_asset" >&2
  exit 1
fi

echo "No preview assets found in $bundle_path"
