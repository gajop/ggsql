#!/usr/bin/env python3
"""Load gapminder.tsv into a SQLite database.

Usage: python3 import_gapminder.py <tsv_path> <db_path>
"""
import csv
import sqlite3
import sys

tsv_path, db_path = sys.argv[1], sys.argv[2]

conn = sqlite3.connect(db_path)
conn.execute("DROP TABLE IF EXISTS gapminder")
conn.execute("""
    CREATE TABLE gapminder (
        country   TEXT,
        continent TEXT,
        year      INTEGER,
        lifeExp   REAL,
        pop       INTEGER,
        gdpPercap REAL
    )
""")

with open(tsv_path, newline="") as f:
    for row in csv.DictReader(f, delimiter="\t"):
        conn.execute("INSERT INTO gapminder VALUES (?,?,?,?,?,?)", (
            row["country"], row["continent"],
            int(row["year"]), float(row["lifeExp"]),
            int(row["pop"]),  float(row["gdpPercap"]),
        ))

conn.commit()
n = conn.execute("SELECT COUNT(*) FROM gapminder").fetchone()[0]
print(f"{n} rows written to {db_path}")
conn.close()
