#!/usr/bin/env python3
"""Wrap a Vega-Lite JSON spec in a standalone HTML page.

Usage: python3 make_html.py <spec.vl.json> <output.html>
"""
import json
import sys

spec = json.load(open(sys.argv[1]))

# "container" sizing tells vega-lite to read the div's rendered dimensions.
# When opened as a standalone HTML file the div has no intrinsic size, so
# the chart renders at 0×0.  Drop these keys so vega-lite uses its defaults.
spec.pop("width", None)
spec.pop("height", None)

spec_json = json.dumps(spec).replace("</", "<\\/")

html = """<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ggsql chart</title>
  <script src="https://cdn.jsdelivr.net/npm/vega@6"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-lite@6"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-embed@7"></script>
  <style>body { margin: 2rem; font-family: sans-serif; }</style>
</head>
<body>
  <div id="vis"></div>
  <script>
    vegaEmbed('#vis', SPEC_PLACEHOLDER, {renderer: 'canvas'}).catch(console.error);
  </script>
</body>
</html>""".replace("SPEC_PLACEHOLDER", spec_json)

with open(sys.argv[2], "w") as f:
    f.write(html)
