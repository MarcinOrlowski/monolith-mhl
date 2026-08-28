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

set -euo pipefail

QSB="${QSB:-/usr/lib/qt6/bin/qsb}"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Every effect keeps its shaders in <effect>/shaders/, so discover them by glob
# rather than listing each one: adding an effect that follows the layout needs
# no edit here. The shared filter shaders live outside that tree, so they are
# appended explicitly.
SHADER_DIRS=()
for dir in "${ROOT_DIR}"/src/contents/ui/effects/*/shaders; do
    [ -d "${dir}" ] && SHADER_DIRS+=("${dir}")
done
[ -d "${ROOT_DIR}/src/contents/ui/filters/shaders" ] \
    && SHADER_DIRS+=("${ROOT_DIR}/src/contents/ui/filters/shaders")

if [ "${#SHADER_DIRS[@]}" -eq 0 ]; then
    echo "No shader directories found under ${ROOT_DIR}/src/contents/ui" >&2
    exit 1
fi

if [ ! -x "${QSB}" ]; then
    echo "qsb not found or not executable: ${QSB}" >&2
    echo "Install qt6-shader-baker, or set QSB=/path/to/qsb" >&2
    exit 1
fi

for SHADER_DIR in "${SHADER_DIRS[@]}"; do
    echo "Compiling ${SHADER_DIR#"${ROOT_DIR}/"}…"
    for src in "${SHADER_DIR}"/*.vert "${SHADER_DIR}"/*.frag; do
        [ -f "${src}" ] || continue
        echo "  $(basename "${src}")…"
        "${QSB}" --glsl "150,310 es" -o "${src}.qsb" "${src}"
    done
done

echo "Done."
