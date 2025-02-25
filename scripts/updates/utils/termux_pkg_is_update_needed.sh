#!/bin/bash
#
# NOTE: This function returns true even when CURRENT_VERSION = "1.0" and LATEST_VERSION = "1.0-1".
# This is logically correct, but repology sometimes returns "1.0-1" as the latest version even
# if "1.0" is latest. This happens when any of the repositories tracked by repology has specified
# "1.0-1" as the latest.
#
# For example:
# latest lua:lpeg version (as of 2021-11-20T12:21:31) is "1.0.2" but MacPorts specifies as "1.0.2-1".
# Hence repology returns "1.0.2-1" as the latest.
#
# But hopefully, all this can be avoided if TERMUX_PKG_AUTO_UPDATE_TAG_REGEXP is set.
#
termux_pkg_is_update_needed() {
	# USAGE: termux_pkg_is_update_needed <current-version> <latest-version> [regexp]

	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		termux_error_exit "${BASH_SOURCE[0]}: at least 2 arguments expected"
	fi

	local CURRENT_VERSION="$1"
	local LATEST_VERSION="$2"
	local VERSION_REGEX="${3:-}"

	# If needed, filter version numbers from tag by using regexp.
	if [[ -n "${VERSION_REGEX}" ]]; then
		LATEST_VERSION="$(grep -oP "${VERSION_REGEX}" <<<"${LATEST_VERSION}" || true)"

		if [[ -z "${LATEST_VERSION}" ]]; then
			termux_error_exit <<-EndOfError
				ERROR: failed to compare versions. Ensure whether the version regex '${VERSION_REGEX}'
				works correctly with given versions.
			EndOfError
		fi
	fi

	# Translate "_" into ".": some packages use underscores to seperate
	# version numbers, but we require them to be separated by dots.
	LATEST_VERSION="${LATEST_VERSION//_/.}"

	# Compare versions.
	# shellcheck disable=SC2091
	if $(
		cat <<-EOF | python3 -
			import sys

			from pkg_resources import parse_version

			if parse_version("${CURRENT_VERSION}") < parse_version("${LATEST_VERSION}"):
			    sys.exit(0)
			else:
			    sys.exit(1)
		EOF
	); then
		return 0 # true. Update needed.
	fi
	return 1 # false. Update not needed.
}

show_help() {
	echo "Usage: ${BASH_SOURCE[0]} [--help] <first-version> <second-version>] [version-regex]"
	echo "--help - show this help message and exit"
	echo "  <first-version> - first version to compare"
	echo "  <second-version> - second version to compare"
	echo "  [version-regex] - optional regular expression to filter version numbers"
	exit 0
}

# Make script sourceable as well as executable.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	declare -f termux_error_exit >/dev/null ||
		. "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/termux_error_exit.sh" # realpath is used to resolve symlinks.

	if [[ "${1}" == "--help" ]]; then
		show_help
	fi

	# Print in human readable format.
	first_version="$1"
	second_version="$2"
	version_regexp="${3:-}"
	if termux_pkg_is_update_needed "${first_version}" "${second_version}" "${version_regexp}"; then
		echo "${first_version} < ${second_version}"
	else
		echo "${first_version} >= ${second_version}"
	fi
fi
