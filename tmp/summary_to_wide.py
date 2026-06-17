#!/usr/bin/env python3
"""Convert execute-results-summary.csv into one row per query.

Input summary format:
query|sample_round|performance_iterations|param_count|avg_time_seconds
tcr-1|1|5|10|0.123
tcr-1|2|5|10|0.456

Output format:
query,t1,t2
tcr-1,0.123,0.456
"""

from __future__ import annotations

import argparse
import csv
from collections import OrderedDict
from pathlib import Path


def detect_dialect(path: Path) -> csv.Dialect:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        sample = handle.read(4096)
    try:
        return csv.Sniffer().sniff(sample, delimiters="|,\t")
    except csv.Error:
        class PipeDialect(csv.Dialect):
            delimiter = "|"
            quotechar = '"'
            escapechar = None
            doublequote = True
            skipinitialspace = False
            lineterminator = "\n"
            quoting = csv.QUOTE_MINIMAL

        return PipeDialect


def convert(input_path: Path, output_path: Path) -> None:
    dialect = detect_dialect(input_path)
    rows_by_query: OrderedDict[str, list[str]] = OrderedDict()

    with input_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle, dialect=dialect)
        required = {"query", "avg_time_seconds"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"missing required columns in {input_path}: {sorted(missing)}")
        for row in reader:
            query = (row.get("query") or "").strip()
            value = (row.get("avg_time_seconds") or "").strip()
            if not query:
                continue
            rows_by_query.setdefault(query, []).append(value)

    max_count = max((len(values) for values in rows_by_query.values()), default=0)
    fieldnames = ["query"] + [f"t{i}" for i in range(1, max_count + 1)]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for query, values in rows_by_query.items():
            out_row = {"query": query}
            out_row.update({f"t{i}": value for i, value in enumerate(values, start=1)})
            writer.writerow(out_row)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("summary_csv", type=Path, help="path to execute-results-summary.csv")
    parser.add_argument(
        "-o",
        "--out",
        type=Path,
        default=None,
        help="output CSV path; default: <input stem>-wide.csv beside input",
    )
    args = parser.parse_args()

    input_path = args.summary_csv
    if not input_path.exists():
        raise FileNotFoundError(input_path)
    output_path = args.out or input_path.with_name(f"{input_path.stem}-wide{input_path.suffix}")
    convert(input_path, output_path)
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
