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

VL_JSON="$(mktemp /tmp/ggsql.XXXXXX.vl.json)"
trap 'rm -f "$VL_JSON"' EXIT

ggsql run "$QUERY_FILE" ${READER_ARGS[@]+"${READER_ARGS[@]}"} > "$VL_JSON"
vl-convert "vl2${EXT}" -i "$VL_JSON" -o "$OUTPUT"
echo "$OUTPUT"
