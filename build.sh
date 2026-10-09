#!/bin/sh
# Assemble the three demos with NASM and enforce two size gates per demo:
#   class  = the size class it belongs to (8, 128, 256 bytes) - a hard ceiling;
#   budget = the size it has been shrunk to - it may not grow back.
set -eu
cd "$(dirname "$0")"
command -v nasm >/dev/null 2>&1 || { echo 'ERROR: NASM is required.' >&2; exit 1; }
fail=0
for spec in uber8:8:5 uber128:128:79 uber256:256:171; do
    name=${spec%%:*}; rest=${spec#*:}; class=${rest%%:*}; budget=${rest##*:}
    upper=$(echo "$name" | tr 'a-z' 'A-Z')
    nasm -f bin -Wall -Werror "src/$name.asm" -o "$upper.COM"
    size=$(wc -c < "$upper.COM" | tr -d ' ')
    printf '%-12s %3s bytes (class %3s, budget %3s)\n' "$upper.COM" "$size" "$class" "$budget"
    [ "$size" -le "$class" ] || { echo "ERROR: $upper.COM exceeds its $class-byte class" >&2; fail=1; }
    [ "$size" -le "$budget" ] || { echo "ERROR: $upper.COM grew past its $budget-byte budget" >&2; fail=1; }
done
[ "$fail" -eq 0 ] || exit 2
if command -v sha256sum >/dev/null 2>&1; then sha256sum UBER8.COM UBER128.COM UBER256.COM > SHA256SUMS; else shasum -a 256 UBER8.COM UBER128.COM UBER256.COM > SHA256SUMS; fi
cat SHA256SUMS
