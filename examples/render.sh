#!/usr/bin/env bash
# Render a ggsql query file to SVG or PNG.
# Usage: bash examples/render.sh <query.ggsql> [output.svg|output.png] [--reader <conn>]
#
# Requires: ggsql CLI and vl-convert on PATH.
# Install vl-convert: download from https://github.com/vega/vl-convert/releases
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <query.ggsql> [output.svg|output.png] [--reader <conn>]" >&2
    exit 1
fi

QUERY_FILE="$1"
shift

# Collect remaining args (output path and/or --reader)
OUTPUT=""
READER_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --reader) READER_ARGS=(--reader "$2"); shift 2 ;;
        *)        OUTPUT="$1"; shift ;;
    esac
done

if [[ -z "$OUTPUT" ]]; then
    OUTPUT="${QUERY_FILE%.ggsql}.svg"
fi

EXT="${OUTPUT##*.}"
if [[ "$EXT" != "svg" && "$EXT" != "png" ]]; then
    echo "Output must be .svg or .png" >&2
    exit 1
fi

RAW_JSON="$(mktemp /tmp/ggsql.XXXXXX.vl.json)"
VL_JSON="$(mktemp /tmp/ggsql.XXXXXX.vl.json)"
trap 'rm -f "$RAW_JSON" "$VL_JSON"' EXIT

ggsql run "$QUERY_FILE" ${READER_ARGS[@]+"${READER_ARGS[@]}"} > "$RAW_JSON"

# Strip "container" sizing — vl-convert has no DOM to measure, so container
# width/height resolves to 0 and the chart renders empty.
python3 -c "
import json, sys
s = json.load(open(sys.argv[1]))
s.pop('width', None)
s.pop('height', None)
json.dump(s, open(sys.argv[2], 'w'))
" "$RAW_JSON" "$VL_JSON"

vl-convert "vl2${EXT}" --vl-version 6.1 -i "$VL_JSON" -o "$OUTPUT"
echo "$OUTPUT"
