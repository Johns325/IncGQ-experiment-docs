#!/usr/bin/env python3
"""Prepare DBLP XML for Neo4j admin import.

This script builds a practical GraphDBLP-like core graph from the official
DBLP XML dump. It does not reproduce GraphDBLP's embedding-based scores.
"""

from __future__ import annotations

import argparse
import csv
import gzip
import hashlib
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

try:
    from lxml import etree
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Missing dependency: lxml. Install it with `python3 -m pip install lxml`."
    ) from exc


PUB_TAGS = {
    "article",
    "inproceedings",
    "proceedings",
    "book",
    "incollection",
    "phdthesis",
    "mastersthesis",
    "www",
    "data",
}

VENUE_FIELDS = (
    ("journal", "journal"),
    ("booktitle", "booktitle"),
    ("school", "school"),
    ("publisher", "publisher"),
)

WORD_RE = re.compile(r"[a-z0-9]+")


def stable_id(prefix: str, value: str) -> str:
    digest = hashlib.sha1(value.encode("utf-8")).hexdigest()
    return f"{prefix}:{digest}"


def clean_text(value: Optional[str]) -> str:
    if not value:
        return ""
    return " ".join(value.split())


def first_child_text(elem: etree._Element, name: str) -> str:
    child = elem.find(name)
    if child is None:
        return ""
    return clean_text("".join(child.itertext()))


def child_texts(elem: etree._Element, name: str) -> List[str]:
    values: List[str] = []
    for child in elem.findall(name):
        value = clean_text("".join(child.itertext()))
        if value:
            values.append(value)
    return values


def normalize_tokens(value: str) -> Tuple[str, ...]:
    return tuple(WORD_RE.findall(value.lower()))


def normalize_keyword(value: str) -> str:
    value = value.strip().strip('"').strip()
    return "_".join(WORD_RE.findall(value.lower()))


def load_keywords(path: Optional[Path]) -> Dict[str, List[Tuple[Tuple[str, ...], str]]]:
    index: Dict[str, List[Tuple[Tuple[str, ...], str]]] = {}
    if path is None:
        return index

    with path.open(newline="", encoding="utf-8") as fh:
        reader = csv.reader(fh)
        for row in reader:
            if not row:
                continue
            key = normalize_keyword(row[0])
            if not key or key in {"n_key", "n.key"}:
                continue
            tokens = tuple(key.split("_"))
            if not tokens:
                continue
            index.setdefault(tokens[0], []).append((tokens, key))

    for candidates in index.values():
        candidates.sort(key=lambda item: len(item[0]), reverse=True)
    return index


def match_keywords(
    title: str, keyword_index: Dict[str, List[Tuple[Tuple[str, ...], str]]]
) -> Set[str]:
    if not keyword_index or not title:
        return set()

    tokens = normalize_tokens(title)
    matches: Set[str] = set()
    for pos, token in enumerate(tokens):
        for candidate_tokens, keyword in keyword_index.get(token, []):
            end = pos + len(candidate_tokens)
            if tuple(tokens[pos:end]) == candidate_tokens:
                matches.add(keyword)
    return matches


def open_xml(path: Path):
    if path.suffix == ".gz":
        return gzip.open(path, "rb")
    return path.open("rb")


def sqlite_connect(path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA synchronous=OFF")
    conn.execute("PRAGMA temp_store=MEMORY")
    conn.execute("CREATE TABLE IF NOT EXISTS authors (id TEXT PRIMARY KEY, name TEXT)")
    conn.execute(
        "CREATE TABLE IF NOT EXISTS venues (id TEXT PRIMARY KEY, name TEXT, type TEXT)"
    )
    conn.execute("CREATE TABLE IF NOT EXISTS keywords (id TEXT PRIMARY KEY, key TEXT)")
    conn.execute(
        "CREATE TABLE IF NOT EXISTS contributed_to (author_id TEXT, venue_id TEXT, "
        "PRIMARY KEY(author_id, venue_id))"
    )
    return conn


def write_header(path: Path, header: Sequence[str]):
    fh = path.open("w", newline="", encoding="utf-8")
    writer = csv.writer(fh)
    writer.writerow(header)
    return fh, writer


def dump_table(
    conn: sqlite3.Connection,
    query: str,
    path: Path,
    header: Sequence[str],
) -> int:
    count = 0
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(header)
        for row in conn.execute(query):
            writer.writerow(row)
            count += 1
    return count


def venue_for(elem: etree._Element) -> Tuple[str, str]:
    for field, venue_type in VENUE_FIELDS:
        value = first_child_text(elem, field)
        if value:
            return value, venue_type
    return "", ""


def publication_id(elem: etree._Element, fallback: int) -> str:
    key = elem.get("key")
    if key:
        return key
    return f"generated:{fallback}"


def prepare(args: argparse.Namespace) -> None:
    out_dir = args.out_dir.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    keyword_index = load_keywords(args.keywords)
    conn = sqlite_connect(out_dir / "dedupe.sqlite")

    publications_fh, publications = write_header(
        out_dir / "publications.csv",
        ["id:ID(publication)", "key", "title", "year:int", "type", "venue"],
    )
    authored_fh, authored = write_header(
        out_dir / "authored.csv",
        [":START_ID(publication)", ":END_ID(author)", "author_order:int"],
    )
    contains_fh, contains = write_header(
        out_dir / "contains.csv",
        [":START_ID(publication)", ":END_ID(keyword)"],
    )

    stats = {
        "publications": 0,
        "authored": 0,
        "contains": 0,
        "contributed_to": 0,
    }

    source = open_xml(args.xml)
    try:
        context = etree.iterparse(
            source,
            events=("end",),
            load_dtd=True,
            resolve_entities=True,
            huge_tree=True,
            recover=args.recover,
        )

        for _, elem in context:
            if elem.tag not in PUB_TAGS:
                continue

            stats["publications"] += 1
            pub_id = publication_id(elem, stats["publications"])
            key = elem.get("key") or pub_id
            pub_type = elem.tag
            title = first_child_text(elem, "title")
            year = first_child_text(elem, "year")
            venue_name, venue_type = venue_for(elem)
            venue_id = stable_id("venue", venue_name.lower()) if venue_name else ""

            publications.writerow([pub_id, key, title, year, pub_type, venue_name])

            if venue_name:
                conn.execute(
                    "INSERT OR IGNORE INTO venues(id, name, type) VALUES (?, ?, ?)",
                    (venue_id, venue_name, venue_type),
                )

            for position, author_name in enumerate(child_texts(elem, "author"), start=1):
                author_id = stable_id("author", author_name)
                conn.execute(
                    "INSERT OR IGNORE INTO authors(id, name) VALUES (?, ?)",
                    (author_id, author_name),
                )
                authored.writerow([pub_id, author_id, position])
                stats["authored"] += 1
                if venue_id:
                    conn.execute(
                        "INSERT OR IGNORE INTO contributed_to(author_id, venue_id) "
                        "VALUES (?, ?)",
                        (author_id, venue_id),
                    )

            for keyword in sorted(match_keywords(title, keyword_index)):
                keyword_id = f"keyword:{keyword}"
                conn.execute(
                    "INSERT OR IGNORE INTO keywords(id, key) VALUES (?, ?)",
                    (keyword_id, keyword),
                )
                contains.writerow([pub_id, keyword_id])
                stats["contains"] += 1

            if stats["publications"] % args.commit_every == 0:
                conn.commit()
                print(
                    f"processed publications={stats['publications']:,}",
                    file=sys.stderr,
                    flush=True,
                )

            if args.limit and stats["publications"] >= args.limit:
                break

            elem.clear()
            parent = elem.getparent()
            if parent is not None:
                while elem.getprevious() is not None:
                    del parent[0]
    finally:
        source.close()
        publications_fh.close()
        authored_fh.close()
        contains_fh.close()

    conn.commit()

    author_count = dump_table(
        conn,
        "SELECT id, name FROM authors ORDER BY id",
        out_dir / "authors.csv",
        ["id:ID(author)", "name"],
    )
    venue_count = dump_table(
        conn,
        "SELECT id, name, type FROM venues ORDER BY id",
        out_dir / "venues.csv",
        ["id:ID(venue)", "name", "type"],
    )
    keyword_count = dump_table(
        conn,
        "SELECT id, key FROM keywords ORDER BY id",
        out_dir / "keywords.csv",
        ["id:ID(keyword)", "key"],
    )
    contributed_count = dump_table(
        conn,
        "SELECT author_id, venue_id FROM contributed_to ORDER BY author_id, venue_id",
        out_dir / "contributed_to.csv",
        [":START_ID(author)", ":END_ID(venue)"],
    )
    conn.close()

    stats["authors"] = author_count
    stats["venues"] = venue_count
    stats["keywords"] = keyword_count
    stats["contributed_to"] = contributed_count

    command_path = out_dir / "neo4j-admin-import-graphdblp-core.sh"
    command_path.write_text(
        "\n".join(
            [
                "#!/usr/bin/env bash",
                "set -euo pipefail",
                ': "${NEO4J_HOME:?set NEO4J_HOME}"',
                ': "${GRAPHDBLP_DATABASE:=graphdblp_core}"',
                f'CSV_DIR="{out_dir}"',
                '"$NEO4J_HOME/bin/neo4j-admin" database import full \\',
                '  --overwrite-destination=true \\',
                '  --id-type=string \\',
                '  --nodes=author="$CSV_DIR/authors.csv" \\',
                '  --nodes=publication="$CSV_DIR/publications.csv" \\',
                '  --nodes=venue="$CSV_DIR/venues.csv" \\',
                '  --nodes=keyword="$CSV_DIR/keywords.csv" \\',
                '  --relationships=authored="$CSV_DIR/authored.csv" \\',
                '  --relationships=contains="$CSV_DIR/contains.csv" \\',
                '  --relationships=contributed_to="$CSV_DIR/contributed_to.csv" \\',
                '  "$GRAPHDBLP_DATABASE"',
                "",
            ]
        ),
        encoding="utf-8",
    )
    command_path.chmod(0o755)

    print("Wrote CSV files to", out_dir)
    for key in sorted(stats):
        print(f"{key}: {stats[key]:,}")
    print("Import command:", command_path)


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert DBLP XML into Neo4j admin-import CSV files."
    )
    parser.add_argument("--xml", required=True, type=Path, help="Path to dblp.xml or dblp.xml.gz")
    parser.add_argument(
        "--keywords",
        type=Path,
        help="Optional GraphDBLP keywords.csv; matched against publication titles.",
    )
    parser.add_argument("--out-dir", required=True, type=Path, help="Output CSV directory")
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Only parse this many publications; useful for smoke tests.",
    )
    parser.add_argument(
        "--commit-every",
        type=int,
        default=100000,
        help="SQLite commit interval.",
    )
    parser.add_argument(
        "--recover",
        action="store_true",
        help="Ask lxml to recover from XML errors. Prefer leaving this off for full imports.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    prepare(parse_args(argv))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
