#!/usr/bin/env bash

# Inspired by https://github.com/rustybird/qubes-stuff/blob/master/dom0/bin/qvm-shell

if test -t 0; then
	OLD_STUFF="$(stty -g)"
	
	trap "stty ${OLD_STUFF}" EXIT
	# This will restore all the terminal shenanigans when the script interpreter quits.

	stty -echo -icanon
	# The generated pseudo-terminal already does this.
fi

run-in-vm.sh "${1}" "LC_CTYPE=C exec script --quiet --return /dev/null"

