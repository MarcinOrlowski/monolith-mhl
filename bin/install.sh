#!/bin/bash
####################################################################
#
# Monolith MHL live wallpapers for Plasma 6
#
# Author Marcin Orlowski <mail@MarcinOrlowski.com>
#
####################################################################

set -e

SRC_DIR="$(dirname "$0")/../src"
PLUGIN_ID="$(jq -r .KPlugin.Id "${SRC_DIR}/metadata.json")"

# Remove old version if installed (in blind)
kpackagetool6 -t Plasma/Wallpaper -r "${PLUGIN_ID}" 2>/dev/null || true
# Install
kpackagetool6 -t Plasma/Wallpaper -i "${SRC_DIR}"

echo "Installed. Restart plasma with:"
echo "  systemctl --user restart plasma-plasmashell.service"
