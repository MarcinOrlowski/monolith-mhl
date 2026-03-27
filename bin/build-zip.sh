#!/bin/bash

#==============================================================================
#
# Monolith MHL live wallpapers for Plasma 6
#
# Author Marcin Orlowski <mail@MarcinOrlowski.com>
#
#==============================================================================
#
# DESCRIPTION:
#   This script builds a .zip package for the Monolith MHL wallpaper.
#   The package will be shared as release artefact but also uploaded to
#   KDE Store.
#
# USAGE:
#   bin/build-zip-package.sh
# OUTPUT:
#   Creates release ZIP archive in the current directory
#
#==============================================================================

set -uo pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
readonly ROOT_DIR
pushd "${ROOT_DIR}" > /dev/null || exit

SOURCE_DIR="${ROOT_DIR}/src"
BUILD_DIR="${ROOT_DIR}/build"

# Package information
PKG_NAME="monolith-mhl-wallpaper"
ARCH="all"

# Validate source directory exists
if [ ! -d "${SOURCE_DIR}" ]; then
    echo "ERROR: Source directory not found: ${SOURCE_DIR}"
    echo "Please ensure you're running this script from the project root."
    exit 1
fi

# Read version from metadata.desktop file
METADATA_FILE="${ROOT_DIR}/src/metadata.json"
if [ ! -f "${METADATA_FILE}" ]; then
    echo "ERROR: Metadata file not found: ${METADATA_FILE}"
    exit 1
fi

VERSION=$(jq -r ".KPlugin.Version" "${METADATA_FILE}")
echo "Version read from metadata: ${VERSION}"

# Directories
THEME_INSTALL_DIR="${BUILD_DIR}/com.marcinorlowski.monolithmhl"

echo "Building package: ${PKG_NAME}_${VERSION}_${ARCH}.zip"
echo

echo "Preparing build directory…"
rm -rf "${BUILD_DIR}"
mkdir -p "${THEME_INSTALL_DIR}"

echo "Copying project files…"
cp -r "${SOURCE_DIR}"/* ./LICENSE.md ./README.md "${THEME_INSTALL_DIR}/"

cd "${BUILD_DIR}" || exit

# Move package to project root
ZIP_DIR="${ROOT_DIR}"
ZIP_FILE="${PKG_NAME}_${VERSION}_${ARCH}.zip"
ZIP_FULL="${ZIP_DIR}/${ZIP_FILE}"

# Create ZIP archive
zip -rq "${ZIP_FILE}" "com.marcinorlowski.monolithmhl"
mv "${ZIP_FILE}" "${ZIP_DIR}/"

echo
echo "=== Package built successfully! ==="
echo "Package: ${ZIP_FILE}"
echo "Size: $(du -h "${ZIP_FULL}" | cut -f1)"
echo

rm -rf "${BUILD_DIR}"
