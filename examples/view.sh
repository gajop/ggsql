#!/usr/bin/env bash
# Open a Vega-Lite JSON file in the browser.
# Usage: bash examples/view.sh chart.vl.json
#
# Requires: python3 (stdlib only)
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <chart.vl.json>" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HTML_FILE="/tmp/ggsql_chart_$$.html"

python3 "$SCRIPT_DIR/make_html.py" "$1" "$HTML_FILE"
echo "Chart: $HTML_FILE"

if command -v xdg-open &>/dev/null; then
    xdg-open "$HTML_FILE"
elif command -v open &>/dev/null; then
    open "$HTML_FILE"
else
    echo "Open in your browser: file://$HTML_FILE"
fi
