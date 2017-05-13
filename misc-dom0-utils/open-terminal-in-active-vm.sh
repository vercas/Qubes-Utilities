#!/usr/bin/env bash

set -e
set -o pipefail
# Fail fast, fail hard.

VMNAME_PROP="_QUBES_VMNAME"
EXTRACT_VM_REGEX="^${VMNAME_PROP}\\(STRING\\) = \"([a-zA-Z0-9_-]+)\"$"

TERMINALS="gnome-terminal || konsole || xfce4-terminal || xterm"

ACTIVE_WIN="$(xdotool getwindowfocus)"
ACTIVE_VM="$(xprop -id "${ACTIVE_WIN}" "${VMNAME_PROP}")"

if [[ $ACTIVE_VM =~ $EXTRACT_VM_REGEX ]]; then
	ACTIVE_VM="${BASH_REMATCH[1]}"
	/usr/lib/qubes/qrexec-client -d "${ACTIVE_VM}" -e "user:${TERMINALS}"
else
	bash -c "${TERMINALS}"
fi

