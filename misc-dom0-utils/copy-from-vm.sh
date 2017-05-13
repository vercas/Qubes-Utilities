#!/usr/bin/env bash

if ! qvm-check --running "${1}" 2>/dev/null; then
	echo "VM ${1} is not running." 1>&2
	exit 1
fi

if test -t 1; then
	echo "Output of this command must not be directed to a terminal!" 1>&2;
	exit 2
fi

/usr/lib/qubes/qrexec-client -d "${1}" "root:cat ${*:2}"

