#!/bin/bash
####################################################################
#
# Monolith MHL live wallpapers for Plasma 6
#
# Author Marcin Orlowski <mail@MarcinOrlowski.com>
#
####################################################################

set -e

QSB="${QSB:-/usr/lib/qt6/bin/qsb}"
SHADER_DIRS=(
    "src/contents/ui/effects/rainbow-waves/shaders"
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
