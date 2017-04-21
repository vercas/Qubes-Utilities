#!/usr/bin/env bash

TEMP=$(mktemp)
cat - > $TEMP

FILE="$(hostname)-$(echo "$(date +%s)${TEMP}" | md5sum | head -c 32)$1"
REMOTE="webroot/${FILE}"

BATCH=$(mktemp)
cat - > $BATCH <<EndOfBatch
put $TEMP $REMOTE
chmod 664 $REMOTE
EndOfBatch

if sftp -q -b "$BATCH" "user@my.domain.com" 1>&2; then
    rm "$BATCH"
    rm "$TEMP"

    echo "FILE:" "$FILE"
else
    echo "SFTP operation failed!" 1>&2
    exit 1
fi

