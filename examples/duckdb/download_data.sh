#!/usr/bin/env bash
# Download the Gapminder dataset and prepare it for the ggsql Gapminder examples.
# Run from the repository root:  bash examples/duckdb/download_data.sh
#
# Requires: curl, python3 (stdlib only — no extra packages needed)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
mkdir -p "$DATA_DIR"

# Gapminder — 1704 rows, 6 columns
# Source: https://github.com/jennybc/gapminder
echo "Downloading gapminder.tsv..."
curl -sSL \
  "https://raw.githubusercontent.com/jennybc/gapminder/main/inst/extdata/gapminder.tsv" \
  -o "$DATA_DIR/gapminder.tsv"
echo "  $(wc -l < "$DATA_DIR/gapminder.tsv") lines downloaded"

echo "Creating SQLite database ($DATA_DIR/gapminder.db)..."
python3 "$SCRIPT_DIR/import_gapminder.py" "$DATA_DIR/gapminder.tsv" "$DATA_DIR/gapminder.db"

echo ""
echo "Done. Run from the repository root:"
echo "  ggsql run examples/duckdb/gapminder_line.ggsql   --reader sqlite://examples/duckdb/data/gapminder.db > gapminder_line.vl.json"
echo "  ggsql run examples/duckdb/gapminder_bubble.ggsql --reader sqlite://examples/duckdb/data/gapminder.db > gapminder_bubble.vl.json"
