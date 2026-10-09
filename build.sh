#!/bin/sh
# Assemble the three demos with NASM and enforce each one's size limit.
set -eu
cd "$(dirname "$0")"
command -v nasm >/dev/null 2>&1 || { echo 'ERROR: NASM is required.' >&2; exit 1; }
fail=0
for spec in uber8:8 uber128:128 uber256:256; do
    name=${spec%%:*}; limit=${spec##*:}
    upper=$(echo "$name" | tr 'a-z' 'A-Z')
    nasm -f bin -Wall -Werror "src/$name.asm" -o "$upper.COM"
    size=$(wc -c < "$upper.COM" | tr -d ' ')
    printf '%-12s %3s bytes (limit %3s, %3s to spare)\n' "$upper.COM" "$size" "$limit" "$((limit - size))"
    [ "$size" -le "$limit" ] || { echo "ERROR: $upper.COM exceeds $limit bytes" >&2; fail=1; }
done
[ "$fail" -eq 0 ] || exit 2
if command -v sha256sum >/dev/null 2>&1; then sha256sum UBER8.COM UBER128.COM UBER256.COM > SHA256SUMS; else shasum -a 256 UBER8.COM UBER128.COM UBER256.COM > SHA256SUMS; fi
cat SHA256SUMS
