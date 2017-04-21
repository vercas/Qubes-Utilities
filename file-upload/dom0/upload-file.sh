#!/usr/bin/env bash

#########################
#   First, sanity checks.

if [ ! -r "$1" ]; then
	echo "Script must be invoked with a readable file as argument." 1>&2
	exit 1
fi

if [ ! -r ~/.yourls.key ]; then
	echo "Please put your YoURLs key in ~/.yourls.key" 1>&2
	exit 1
fi

######################
#   Some basic info...

EXT=$([[ "${1}" = *.* ]] && echo ".${1##*.}" || echo '')
YOURLS_KEY=$(cat ~/.yourls.key)

FILE_REGEX="^FILE:\\s*(.*)$"
URL_REGEX="^https://s\\.vercas\\.com/(.*)$"

VMS=(insert vm names here)

#################
#   VM selection.

for vm in "${VMS[@]}"; do
	if qvm-check --running "$vm"; then
		VM="$vm"
		break
	fi
done

if [ -z "$VM" ]; then
	echo "No useable VM is running:" $VMS 1>&2

	read -n 1 -p "Do you wish to start up the first one? (y/Y for yes; anything else for no) " choice

	case "$choice" in
	y|Y ) ;; # Go on.
	* )
		echo "Will not continue." 1>&2
		exit 2
	;;
	esac

	VM=$VMS
	# Will become the first item.
fi

#######################
#   Uploading the file.

FILE_RES=$(qvm-run -a --pass-io $VM "/home/user/bin/upload-file.sh '${EXT}'" < $1)

if [[ $FILE_RES =~ $FILE_REGEX ]]; then
	FILE="${BASH_REMATCH[1]}"
else
	echo "Failed to upload file:" "$1" 1>&2
	echo "Result:" 1>&2
	echo "${FILE_RES}" 1>&2
	exit 3
fi

#######################
#   Shortening the URL.

TIME=$(date +%s)
SIGN=$(echo -n "${TIME}#{YOURLS_KEY}" | md5sum | head -c 32)
URL="https://u.vercas.com/${FILE}"

ACT="https://s.vercas.com/yourls-api.php?timestamp=${TIME}&signature=${SIGN}&action=shorturl&format=simple&url=${URL}"

SHORT_RES=$(qvm-run --pass-io $VM "wget -qO - '${ACT}'")

if [[ $SHORT_RES =~ $URL_REGEX ]]; then
	SHORT="${BASH_REMATCH[1]}"
else
	echo "Failed to shorten URL:" "${URL}" 1>&2
	echo "Result:" 1>&2
	echo "${SHORT_RES}" 1>&2
	exit 4
fi

###########
#   Report.

echo -e "https://s.vercas.com/\e[7m${SHORT}\e[27m"

#####################################
#   Insert into Qubes clipboard (3.1)

echo "https://s.vercas.com/${SHORT}" > /var/run/qubes/qubes-clipboard.bin
echo "dom0" > /var/run/qubes/qubes-clipboard.bin.source

