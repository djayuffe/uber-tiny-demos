#!/bin/sh
# Run one demo in DOSBox:  ./run-dosbox.sh [8|128|256]   (default 256)
# The autoexec lines go into the conf file itself: combining -conf with separate -c
# flags silently throttles cycles=max.
set -eu
DOSBOX_BIN=dosbox
if ! command -v "$DOSBOX_BIN" >/dev/null 2>&1; then
    MAC_APP=/Applications/dosbox.app/Contents/MacOS/DOSBox
    if [ -x "$MAC_APP" ]; then DOSBOX_BIN=$MAC_APP
    else echo "ERROR: DOSBox is required." >&2; exit 1; fi
fi
case "${1:-256}" in 8|128|256) TARGET="UBER${1:-256}.COM" ;; *) echo "usage: $0 [8|128|256]" >&2; exit 1 ;; esac
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
[ -f "$DIR/$TARGET" ] || "$DIR/build.sh" >/dev/null
TMPCONF=$(mktemp /tmp/uber-tiny-dosbox.XXXXXX.conf)
trap 'rm -f "$TMPCONF"' EXIT
grep -v '^\[autoexec\]' "$DIR/DOSBOX.CONF" | grep -v '^#' > "$TMPCONF"
{ echo "[autoexec]"; echo "mount c $DIR"; echo "c:"; echo "$TARGET"; } >> "$TMPCONF"
"$DOSBOX_BIN" -conf "$TMPCONF"
