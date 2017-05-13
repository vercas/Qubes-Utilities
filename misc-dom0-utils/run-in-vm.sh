#!/usr/bin/env bash

if qvm-check --running "${1}" 2>/dev/null; then
	/usr/lib/qubes/qrexec-client -d "${1}" "user:${*:2}"
else
	echo "VM ${1} is not running." 1>&2
	exit 1
fi

