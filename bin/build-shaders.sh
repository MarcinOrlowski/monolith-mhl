#!/bin/bash

# ==============================================================================
#
# Monolith MHL: Beautiful animated wallpapers for Plasma 6
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2025-2026 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# Compiles GLSL shaders to QSB format using Qt Shader Batcher (qsb).
#
# ==============================================================================

set -e

QSB="${QSB:-/usr/lib/qt6/bin/qsb}"
SHADER_DIRS=(
    "src/contents/ui/effects/rainbow-waves/shaders"
    "src/contents/ui/effects/lava-lamp/shaders"
    "src/contents/ui/effects/dot-waves/shaders"
    "src/contents/ui/effects/trippy-tunnel/shaders"
    "src/contents/ui/filters/shaders"
)

ROOT_DIR="$(dirname "$0")/.."

for SHADER_DIR in "${SHADER_DIRS[@]}"; do
    echo "Compiling ${SHADER_DIR}…"
    SHADER_DIR_FULL_PATH="${ROOT_DIR}/${SHADER_DIR}"
    [ -d "${SHADER_DIR_FULL_PATH}" ] || continue
    for src in "${SHADER_DIR_FULL_PATH}"/*.vert "${SHADER_DIR_FULL_PATH}"/*.frag; do
        [ -f "${src}" ] || continue
        BASE_FILE_NAME="$(basename "${src}")"
        out="${src}.qsb"
        echo "  ${BASE_FILE_NAME}…"
        "${QSB}" --glsl "150,310 es" -o "${out}" "${src}"
    done
done

echo "Done."
