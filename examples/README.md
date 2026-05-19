# ggsql Examples

End-to-end examples showing ggsql against real datasets. Each example produces a **Vega-Lite JSON** spec you can view immediately in a browser.

## Prerequisites

**ggsql CLI** — build from source:

```bash
cargo build --release --package ggsql-cli
export PATH="$PWD/target/release:$PATH"
```

**vl-convert** — renders Vega-Lite specs to SVG/PNG without a browser.
Download the binary for your platform from [github.com/vega/vl-convert/releases](https://github.com/vega/vl-convert/releases) and put it on your PATH.

## Rendering output

`ggsql run` outputs Vega-Lite JSON to stdout. To get an image, pipe it through `vl-convert`:

```bash
ggsql run examples/duckdb/penguins_scatter.ggsql > chart.vl.json
vl-convert vl2svg -i chart.vl.json -o chart.svg
vl-convert vl2png -i chart.vl.json -o chart.png
```

`render.sh` is a convenience wrapper that does both steps in one:

```bash
bash examples/render.sh examples/duckdb/penguins_scatter.ggsql penguins_scatter.svg
bash examples/render.sh examples/duckdb/penguins_scatter.ggsql penguins_scatter.png

# With a reader flag:
bash examples/render.sh examples/duckdb/gapminder_bubble.ggsql gapminder_bubble.svg \
  --reader sqlite://examples/duckdb/data/gapminder.db
```

**Browser viewer** (if you don't have vl-convert):

```bash
ggsql run examples/duckdb/penguins_scatter.ggsql > /tmp/chart.vl.json
bash examples/view.sh /tmp/chart.vl.json
```

---

## DuckDB examples

### Quick start — built-in datasets

No download needed. These use ggsql's embedded `penguins` dataset.

```bash
# Scatter plot: bill length vs depth, coloured by species
ggsql run examples/duckdb/penguins_scatter.ggsql > penguins_scatter.vl.json
vl-convert vl2svg -i penguins_scatter.vl.json -o penguins_scatter.svg

# Box plot: body mass by sex, faceted by species
ggsql run examples/duckdb/penguins_faceted.ggsql > penguins_faceted.vl.json
vl-convert vl2png -i penguins_faceted.vl.json -o penguins_faceted.png
```

### Gapminder — real dataset (SQLite backend)

The [Gapminder dataset](https://www.gapminder.org/) contains life expectancy, GDP per capita, and population for 142 countries from 1952–2007 (1 704 rows, ~80 KB).

**Download and import the data:**

```bash
bash examples/duckdb/download_data.sh
# Requires: curl, python3 (stdlib only)
```

This creates `examples/duckdb/data/gapminder.db` (SQLite). The Gapminder examples use the SQLite reader (`--reader sqlite://...`) because the current DuckDB bundled in ggsql-rs does not support column references from `read_csv` / `read_parquet` table functions — DuckDB's built-in tables (like `ggsql:penguins`) and SQLite work without this restriction.

**Run the examples:**

```bash
# Life expectancy over time by continent
ggsql run examples/duckdb/gapminder_line.ggsql \
  --reader sqlite://examples/duckdb/data/gapminder.db > gapminder_line.vl.json
vl-convert vl2svg -i gapminder_line.vl.json -o gapminder_line.svg

# Wealth vs health bubble chart (2007)
ggsql run examples/duckdb/gapminder_bubble.ggsql \
  --reader sqlite://examples/duckdb/data/gapminder.db > gapminder_bubble.vl.json
vl-convert vl2png -i gapminder_bubble.vl.json -o gapminder_bubble.png
```

---

## BigQuery examples

These use [BigQuery public datasets](https://cloud.google.com/bigquery/public-data). BigQuery charges **$5 per TB scanned** with a **1 TB/month free tier** — all examples below are comfortably within that limit:

| Example | Table size | Scanned per run | Cost per run |
|---|---|---|---|
| shakespeare_words / shakespeare_by_corpus | 6.1 MB | 6.1 MB | ~$0.00003 |
| baby_names | 186 MB (5 cols) | ~112 MB (3 cols) | ~$0.0006 |
| nyc_trees | 223 MB (41 cols) | ~11 MB (2 cols) | ~$0.00006 |

All examples are well within the 1 TB/month free tier — you'd need to run them thousands of times in a month to incur any charges. You can always verify bytes scanned in the [BigQuery console](https://console.cloud.google.com/bigquery).

### Authentication setup (one-time)

1. Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).

2. Authenticate with Application Default Credentials:

   ```bash
   gcloud auth application-default login
   ```

3. Note your project ID:

   ```bash
   gcloud config get-value project
   # e.g. my-gcp-project-123
   ```

### Running examples via the Jupyter kernel

In a ggsql notebook cell, switch the connection first:

```
-- @connect: bigquery://YOUR_PROJECT_ID
```

Then run any of the `.ggsql` files directly as cell content.

### Running examples via the CLI

The `--reader` flag for BigQuery is `bigquery://YOUR_PROJECT_ID`:

```bash
ggsql run examples/bigquery/shakespeare_words.ggsql \
  --reader bigquery://YOUR_PROJECT_ID \
  > shakespeare_words.vl.json
```

### Shakespeare — word frequencies

`bigquery-public-data.samples.shakespeare` contains word counts for every word in Shakespeare's complete works.

See [`bigquery/shakespeare_words.ggsql`](bigquery/shakespeare_words.ggsql) — top 20 words longer than 3 letters.

See [`bigquery/shakespeare_by_corpus.ggsql`](bigquery/shakespeare_by_corpus.ggsql) — word count per play/poem.

### US baby names — name popularity over time

`bigquery-public-data.usa_names.usa_1910_current` has name counts by state, year, and gender since 1910.

See [`bigquery/baby_names.ggsql`](bigquery/baby_names.ggsql) — popularity of five names since 1990 as a line chart.

### NYC street trees — species breakdown

`bigquery-public-data.new_york_trees.tree_census_2015` is the 2015 NYC street tree census (683 K trees).

See [`bigquery/nyc_trees.ggsql`](bigquery/nyc_trees.ggsql) — top 15 species by count as a bar chart.

---

## What ggsql can visualize

Every example above uses Vega-Lite as the rendering backend (the only output format today). The output JSON can be rendered:

- In the browser via the [Vega Editor](https://vega.github.io/editor/) or embedded `vega-embed`
- As a static image via `vl-convert`
- Inside Positron / JupyterLab via the ggsql Jupyter kernel (output goes straight to the Plot pane)
- In VS Code / Positron via the ggsql extension

Supported chart types (DRAW clause): `point`, `line`, `bar`, `area`, `ribbon`, `histogram`, `boxplot`, `violin`, `density`, `text`, `range`, `smooth`, `tile`.
