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
# Assembles a grid collage out of the given images
#
# ==============================================================================
#
# USAGE:
#   bin/build-collage.sh -o <OUTPUT> -i <INPUT>... [OPTIONS]
#
#   Images are laid out in the order given, left to right, top to bottom. The
#   options may appear in any order, and every one of them also takes the
#   "--opt=value" spelling; "-i" takes as many file names as follow it and may
#   itself be repeated.
#
#   The collage is always exactly as wide as asked for, ${DEFAULT_OUTPUT_WIDTH}
#   pixels unless "-w" says otherwise; its height follows from the number of
#   images given and their aspect ratios, unless "-h" pins every tile to a fixed
#   height. The output format is picked by ImageMagick from the output file
#   extension.
#
#   Note "-h" is the tile height, not help; use "--help" or "-?" for that.
#
# EXAMPLE:
#   bin/build-collage.sh -o img/themes.webp -i docs/effects/*/img/preview-01.webp
#
# ==============================================================================

set -euo pipefail

# Width of the produced collage, in pixels. Overridable with "-w".
readonly DEFAULT_OUTPUT_WIDTH=1280

# Tiles per row. Overridable with "-c".
readonly DEFAULT_COLUMN_COUNT=2

# Space between tiles, in pixels, both horizontally and vertically. Overridable
# with "-g".
readonly DEFAULT_GAP=4

# Fill used for the gaps and for padding tiles that come up short. Transparent
# by default. Overridable with "-b".
readonly DEFAULT_GAP_COLOR="none"

# Height every tile is forced to, in pixels. Empty means derive it from each
# source image instead. Overridable with "-h".
readonly DEFAULT_TILE_HEIGHT=""

# Compression quality, for output formats that are lossy.
readonly QUALITY=80

# ==============================================================================

function abort {
  echo "*** ${1:-Aborted.}" >&2
  exit 1
}

function usage {
  echo "Assembles a grid collage out of the given images."
  echo
  echo "Usage: $(basename "${0}") -o <OUTPUT> -i <INPUT>... [OPTIONS]"
  echo
  echo "  -o, --output <FILE>     file to write the collage to; format is taken"
  echo "                          from its extension"
  echo "  -i, --input <FILE>...   source images, in layout order (left to right,"
  echo "                          top to bottom); may be given more than once"
  echo "  -w, --width <PIXELS>    width of the collage (default: ${DEFAULT_OUTPUT_WIDTH})"
  echo "  -c, --columns <COUNT>   tiles per row (default: ${DEFAULT_COLUMN_COUNT})"
  echo "  -g, --gap <PIXELS>      space between tiles (default: ${DEFAULT_GAP}); 0 for none"
  echo "  -b, --background <CLR>  gap fill, any ImageMagick colour (default:"
  echo "                          ${DEFAULT_GAP_COLOR}); quote it, as '#' starts a comment:"
  echo "                          -b='#ffffff' or -b \"#ffffff\""
  echo "  -h, --height <PIXELS>   force every tile to this height, cropping to fit"
  echo "                          rather than deriving it from the source images"
  echo "      --help, -?          show this help"
  echo
  echo "Unless -h says otherwise, collage height follows from the number of images"
  echo "given and their aspect ratios."
}

# Aborts unless the given value is a plain integer of at least the given minimum.
#
# Arguments:
#    option: option name, for the error message
#     value: value to check
#       min: smallest value accepted
#
function assertInt {
  local -r _option="${1}"
  local -r _value="${2}"
  local -r _min="${3}"

  [[ "${_value}" =~ ^[0-9]+$ ]] || abort "Option ${_option} needs a number, got '${_value}'."
  [[ "${_value}" -ge "${_min}" ]] || abort "Option ${_option} must be at least ${_min}, got '${_value}'."
}

# ==============================================================================

# ImageMagick 7 renamed "convert" to "magick" and folded the other tools in as
# subcommands, so probe for either.
if command -v magick &>/dev/null; then
  MAGICK=(magick)
  IDENTIFY=(magick identify)
elif command -v convert &>/dev/null && command -v identify &>/dev/null; then
  MAGICK=(convert)
  IDENTIFY=(identify)
else
  abort "ImageMagick is required but not installed."
fi
readonly MAGICK IDENTIFY

# ==============================================================================
# Arguments
# ==============================================================================

if [[ "${#}" -eq 0 ]]; then
  usage
  exit 1
fi

OUTPUT=""
INPUTS=()
OUTPUT_WIDTH="${DEFAULT_OUTPUT_WIDTH}"
COLUMN_COUNT="${DEFAULT_COLUMN_COUNT}"
GAP="${DEFAULT_GAP}"
GAP_COLOR="${DEFAULT_GAP_COLOR}"
TILE_HEIGHT="${DEFAULT_TILE_HEIGHT}"

while [[ "${#}" -gt 0 ]]; do
  # Split "--opt=value" into two arguments before matching, so both spellings
  # work. The "=" form is what quoting a colour gives you: -b="#ffffff" reaches
  # us as the single word -b=#ffffff, since the quotes only stop "#" from
  # opening a comment.
  if [[ "${1}" == -*=* ]]; then
    option="${1%%=*}"
    value="${1#*=}"
    shift
    set -- "${option}" "${value}" "${@}"
  fi

  case "${1}" in
  --help | -\?)
    usage
    exit 0
    ;;
  -o | --output)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    OUTPUT="${2}"
    shift 2
    ;;
  -w | --width)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    assertInt "${1}" "${2}" 1
    OUTPUT_WIDTH="${2}"
    shift 2
    ;;
  -c | --columns)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    assertInt "${1}" "${2}" 1
    COLUMN_COUNT="${2}"
    shift 2
    ;;
  -g | --gap)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    assertInt "${1}" "${2}" 0
    GAP="${2}"
    shift 2
    ;;
  -b | --background)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    GAP_COLOR="${2}"
    shift 2
    ;;
  -h | --height)
    [[ "${#}" -ge 2 ]] || abort "Option ${1} needs a value."
    assertInt "${1}" "${2}" 1
    TILE_HEIGHT="${2}"
    shift 2
    ;;
  -i | --input)
    [[ "${#}" -ge 2 && "${2}" != -* ]] || abort "Option ${1} needs at least one value."
    shift
    while [[ "${#}" -gt 0 && "${1}" != -* ]]; do
      INPUTS+=("${1}")
      shift
    done
    ;;
  *)
    abort "Unknown argument: ${1}. See --help."
    ;;
  esac
done
readonly OUTPUT INPUTS OUTPUT_WIDTH COLUMN_COUNT GAP GAP_COLOR TILE_HEIGHT

# Let ImageMagick be the judge of what is a colour, but ask it now rather than
# halfway through the run. It only *warns* about an unrecognised colour and
# still exits 0, so the exit code tells us nothing and stderr is what counts.
colour_probe="$("${MAGICK[@]}" -size 1x1 "xc:${GAP_COLOR}" null: 2>&1)" || true
[[ -z "${colour_probe}" ]] || abort "Not a colour ImageMagick understands: '${GAP_COLOR}'."
unset colour_probe

[[ -n "${OUTPUT}" ]] || abort "No output file given. See --help."
[[ "${#INPUTS[@]}" -gt 0 ]] || abort "No input images given. See --help."

for input in "${INPUTS[@]}"; do
  [[ -f "${input}" ]] || abort "No such input image: ${input}"
  [[ -r "${input}" ]] || abort "Input image is not readable: ${input}"
done

OUTPUT_DIR="$(dirname "${OUTPUT}")"
readonly OUTPUT_DIR
[[ -d "${OUTPUT_DIR}" ]] || abort "No such output directory: ${OUTPUT_DIR}"
[[ -w "${OUTPUT_DIR}" ]] || abort "Output directory is not writable: ${OUTPUT_DIR}"

# Column widths.
readonly CONTENT_WIDTH=$((OUTPUT_WIDTH - (COLUMN_COUNT - 1) * GAP))
if [[ "${CONTENT_WIDTH}" -lt "${COLUMN_COUNT}" ]]; then
  abort "Width of ${OUTPUT_WIDTH}px is too small for ${COLUMN_COUNT} column(s) with a ${GAP}px gap."
fi

COL_WIDTHS=()
for ((col = 0; col < COLUMN_COUNT; col++)); do
  width=$((CONTENT_WIDTH / COLUMN_COUNT))
  [[ "${col}" -lt $((CONTENT_WIDTH % COLUMN_COUNT)) ]] && width=$((width + 1))
  COL_WIDTHS+=("${width}")
done
readonly COL_WIDTHS

# ==============================================================================

WORK_DIR="$(mktemp -d)"
readonly WORK_DIR
# shellcheck disable=SC2064  # expand WORK_DIR now, while it is still in scope
trap "rm -rf '${WORK_DIR}'" EXIT

# Scale every image to the width of the column it lands in. Height follows from
# the source aspect ratio, unless "-h" pinned it.
echo "Scaling ${#INPUTS[@]} image(s) to ${COLUMN_COUNT} column(s)…"

MEASURED_HEIGHTS=()
for i in "${!INPUTS[@]}"; do
  tile_width="${COL_WIDTHS[$((i % COLUMN_COUNT))]}"
  tile="${WORK_DIR}/tile-${i}.png"

  if [[ -n "${TILE_HEIGHT}" ]]; then
    # "^" scales to cover the tile rather than fit inside it, so the crop that
    # follows trims the overflow instead of the image being squashed to fit.
    echo "  $(basename "${INPUTS[${i}]}") → ${tile_width}x${TILE_HEIGHT}px"
    "${MAGICK[@]}" "${INPUTS[${i}]}" -resize "${tile_width}x${TILE_HEIGHT}^" \
      -gravity center -extent "${tile_width}x${TILE_HEIGHT}" "${tile}"
  else
    echo "  $(basename "${INPUTS[${i}]}") → ${tile_width}px wide"
    "${MAGICK[@]}" "${INPUTS[${i}]}" -resize "${tile_width}x" "${tile}"
  fi

  MEASURED_HEIGHTS+=("$("${IDENTIFY[@]}" -format '%h' "${tile}")")
done

# A row is only as tall as its tallest tile (unless overridden). Anything shorter
# is centred and padded,
readonly ROWS=$(((${#INPUTS[@]} + COLUMN_COUNT - 1) / COLUMN_COUNT))
COLLAGE_HEIGHT=$(((ROWS - 1) * GAP))

ROW_FILES=()
for ((row = 0; row < ROWS; row++)); do
  first=$((row * COLUMN_COUNT))
  last=$((first + COLUMN_COUNT - 1))
  [[ "${last}" -ge "${#INPUTS[@]}" ]] && last=$((${#INPUTS[@]} - 1))

  row_height=0
  for ((i = first; i <= last; i++)); do
    [[ "${MEASURED_HEIGHTS[${i}]}" -gt "${row_height}" ]] && row_height="${MEASURED_HEIGHTS[${i}]}"
  done
  COLLAGE_HEIGHT=$((COLLAGE_HEIGHT + row_height))

  # A zero sized image is an error, so only make a spacer when there is a gap.
  spacer=()
  if [[ "${GAP}" -gt 0 ]]; then
    spacer=("${WORK_DIR}/hspacer-${row}.png")
    "${MAGICK[@]}" -size "${GAP}x${row_height}" "xc:${GAP_COLOR}" "${spacer[0]}"
  fi

  tiles=()
  for ((i = first; i <= last; i++)); do
    tile="${WORK_DIR}/tile-${i}.png"

    # Centre anything shorter than the row within it.
    if [[ "${MEASURED_HEIGHTS[${i}]}" -ne "${row_height}" ]]; then
      padded="${WORK_DIR}/padded-${i}.png"
      "${MAGICK[@]}" "${tile}" -background "${GAP_COLOR}" -gravity center \
        -extent "${COL_WIDTHS[$((i % COLUMN_COUNT))]}x${row_height}" "${padded}"
      tile="${padded}"
    fi

    [[ "${#tiles[@]}" -gt 0 ]] && tiles+=("${spacer[@]}")
    tiles+=("${tile}")
  done

  row_file="${WORK_DIR}/row-${row}.png"
  "${MAGICK[@]}" "${tiles[@]}" +append \
    -background "${GAP_COLOR}" -gravity west -extent "${OUTPUT_WIDTH}x${row_height}" "${row_file}"
  ROW_FILES+=("${row_file}")
done
readonly COLLAGE_HEIGHT

# Stack the rows into the final collage.
echo "Assembling ${ROWS} row(s) into ${OUTPUT_WIDTH}x${COLLAGE_HEIGHT}…"

vspacer=()
if [[ "${GAP}" -gt 0 ]]; then
  vspacer=("${WORK_DIR}/vspacer.png")
  "${MAGICK[@]}" -size "${OUTPUT_WIDTH}x${GAP}" "xc:${GAP_COLOR}" "${vspacer[0]}"
fi

parts=()
for row_file in "${ROW_FILES[@]}"; do
  [[ "${#parts[@]}" -gt 0 ]] && parts+=("${vspacer[@]}")
  parts+=("${row_file}")
done

"${MAGICK[@]}" "${parts[@]}" -background "${GAP_COLOR}" -append \
  -quality "${QUALITY}" "${OUTPUT}"

echo "Done: ${OUTPUT} ($("${IDENTIFY[@]}" -format '%wx%h' "${OUTPUT}"))"
