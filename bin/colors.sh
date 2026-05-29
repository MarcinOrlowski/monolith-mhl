# ==============================================================================
#
# Monolith MHL: Beautiful animated wallpapers for Plasma 6
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2025-2026 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# ==============================================================================

# shellcheck shell=bash  # sourced, not executed (no shebang by design)
# Sourced by other scripts; the color palette below is consumed by callers.
# shellcheck disable=SC2034  # vars are used by sourcing scripts, not within this file
# shellcheck disable=SC2155  # readonly+assign is intentional for this palette

# tput wrapper that returns empty string if $TERM is not set
# which is the case with cron jobs. This affects only colors
# so it' safe to deal with it as here.
#
# Arguments:
# 	Up to 3 arguments, directly passed to tput.
#
# Returns:
#	Returns tput's output or empty string.
#
function TPUT {
	# We need to have $TERM set otherwise tput would fail
	# When invoked by cron, we may or may not have it so...
	if [[ -n "${TERM:-}" && "${TERM}" != "dumb" ]]; then
		# shellcheck disable=SC2086  # intentional word-splitting drops empty optional args
		tput "${1:-}" ${2:-} ${3:-}
	else
		echo -n ""
	fi
}

if [[ -z "${TERM_COLORS_SET:-}" ]]; then
	readonly RESET="$(TPUT sgr 0 0)"
	readonly DIM="$(TPUT dim)"
	readonly REVERSE="$(TPUT rev)"

	readonly FG_BLACK="$(TPUT setaf 0)"
	readonly FG_BLUE="$(TPUT setaf 4)"
	readonly FG_CYAN="$(TPUT setaf 6)"
	readonly FG_GREEN="$(TPUT setaf 2)"
	readonly FG_MAGENTA="$(TPUT setaf 5)"
	readonly FG_RED="$(TPUT setaf 1)"
	readonly FG_WHITE="$(TPUT setaf 7)"
	readonly FG_YELLOW="$(TPUT setaf 3)"
	readonly FG_YELLOW_DIM="${DIM}${FG_YELLOW}"

	readonly BG_BLACK="$(TPUT setab 0)"
	readonly BG_BLUE="$(TPUT setab 4)"
	readonly BG_CYAN="$(TPUT setab 6)"
	readonly BG_GREEN="$(TPUT setab 2)"
	readonly BG_MAGENTA="$(TPUT setab 5)"
	readonly BG_RED="$(TPUT setab 1)"
	readonly BG_WHITE="$(TPUT setab 7)"
	readonly BG_YELLOW="$(TPUT setab 3)"

	# colors by usage role
	readonly OK="${RESET}${FG_GREEN}"
	readonly WARNING="${RESET}${FG_YELLOW}"
	readonly ERROR="${RESET}${FG_RED}"
	readonly NOTICE="${RESET}${FG_CYAN}"

	readonly TERM_COLORS_SET="YES"
fi
