#!/usr/bin/env python3
import argparse
import csv
import os
import shutil
import subprocess
import sys
from collections import Counter
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
PREPARE_SCRIPT = SCRIPT_DIR / "prepare_dblp_for_neo4j_import.py"

NODE_FILES = {
    "author": "authors.csv",
    "publication": "publications.csv",
    "venue": "venues.csv",
    "keyword": "keywords.csv",
}

REL_FILES = {
    "authored": "authored.csv",
    "contains": "contains.csv",
    "contributed_to": "contributed_to.csv",
}


def write_config(target_dir: Path) -> Path:
    conf_dir = target_dir / "conf"
    conf_dir.mkdir(parents=True, exist_ok=True)
    (target_dir / "logs").mkdir(parents=True, exist_ok=True)
    (target_dir / "data").mkdir(parents=True, exist_ok=True)
    (conf_dir / "neo4j.conf").write_text(
        "\n".join(
            [
                f"server.directories.data={target_dir / 'data'}",
                f"server.directories.logs={target_dir / 'logs'}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return conf_dir


def run_prepare(xml: Path, keywords: Path | None, csv_dir: Path, limit: int, recover: bool) -> None:
    cmd = [
        sys.executable,
        str(PREPARE_SCRIPT),
        "--xml",
        str(xml),
        "--out-dir",
        str(csv_dir),
    ]
    if keywords:
        cmd.extend(["--keywords", str(keywords)])
    if limit:
        cmd.extend(["--limit", str(limit)])
    if recover:
        cmd.append("--recover")
    subprocess.run(cmd, check=True)


def require_csv_files(csv_dir: Path) -> None:
    expected = set(NODE_FILES.values()) | set(REL_FILES.values())
    missing = sorted(name for name in expected if not (csv_dir / name).is_file())
    if missing:
        raise SystemExit("Missing expected GraphDBLP CSV files:\n" + "\n".join(missing))


def record_count(path: Path) -> int:
    with path.open("r", encoding="utf-8", newline="") as file:
        reader = csv.reader(file)
        try:
            next(reader)
        except StopIteration:
            return 0
        return sum(1 for _row in reader)


def validate_counts(csv_dir: Path) -> None:
    require_csv_files(csv_dir)
    node_counts = Counter()
    rel_counts = Counter()

    print("Node CSV row counts:")
    for label, filename in NODE_FILES.items():
        rows = record_count(csv_dir / filename)
        node_counts[label] = rows
        print(f"  {filename}: rows={rows}")

    print("Relationship CSV row counts:")
    for rel_type, filename in REL_FILES.items():
        rows = record_count(csv_dir / filename)
        rel_counts[rel_type] = rows
        print(f"  {filename}: rows={rows}")

    print("Node label counts:")
    for label in sorted(node_counts):
        print(f"  {label}: {node_counts[label]}")
    print("Relationship type counts:")
    for rel_type in sorted(rel_counts):
        print(f"  {rel_type}: {rel_counts[rel_type]}")
    print(f"Node input total: {sum(node_counts.values())}")
    print(f"Relationship input total: {sum(rel_counts.values())}")
    print("Count validation passed.")


def run_import(target_dir: Path, csv_dir: Path, neo4j_home: Path, java_home: Path, heap_size: str, verbose: bool) -> None:
    require_csv_files(csv_dir)
    conf_dir = write_config(target_dir)
    cmd = [
        str(neo4j_home / "bin" / "neo4j-admin"),
        "database",
        "import",
        "full",
        "--overwrite-destination=true",
        "--id-type=STRING",
        f"--report-file={target_dir / 'import.report'}",
    ]
    if verbose:
        cmd.append("--verbose")
    cmd.extend(f"--nodes={label}={csv_dir / filename}" for label, filename in NODE_FILES.items())
    cmd.extend(f"--relationships={rel_type}={csv_dir / filename}" for rel_type, filename in REL_FILES.items())

    env = os.environ.copy()
    env["JAVA_HOME"] = str(java_home)
    env["NEO4J_CONF"] = str(conf_dir)
    env["HEAP_SIZE"] = heap_size
    subprocess.run(cmd, env=env, check=True)


def run_check(target_dir: Path, neo4j_home: Path, java_home: Path) -> None:
    env = os.environ.copy()
    env["JAVA_HOME"] = str(java_home)
    env["NEO4J_CONF"] = str(target_dir / "conf")
    subprocess.run([str(neo4j_home / "bin" / "neo4j-admin"), "database", "info", "neo4j"], env=env, check=True)
    subprocess.run([str(neo4j_home / "bin" / "neo4j-admin"), "database", "check", "neo4j"], env=env, check=True)


def cleanup_csv(csv_dir: Path) -> None:
    shutil.rmtree(csv_dir, ignore_errors=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare and import DBLP/GraphDBLP core CSVs into Neo4j 5.")
    parser.add_argument("--xml", type=Path, required=True)
    parser.add_argument("--keywords", type=Path)
    parser.add_argument("--csv-dir", type=Path, required=True)
    parser.add_argument("--target-dir", type=Path, required=True)
    parser.add_argument("--neo4j-home", type=Path, required=True)
    parser.add_argument("--java-home", type=Path, required=True)
    parser.add_argument("--heap-size", default="8G")
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--recover", action="store_true")
    parser.add_argument("--skip-prepare", action="store_true")
    parser.add_argument("--skip-import", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--validate-counts", action="store_true")
    parser.add_argument("--cleanup-csv", action="store_true")
    parser.add_argument("--verbose", action="store_true", help="Pass --verbose to neo4j-admin database import full.")
    args = parser.parse_args()

    if not args.skip_prepare:
        run_prepare(args.xml, args.keywords, args.csv_dir, args.limit, args.recover)
    if args.validate_counts:
        validate_counts(args.csv_dir)
    if not args.skip_import:
        run_import(args.target_dir, args.csv_dir, args.neo4j_home, args.java_home, args.heap_size, args.verbose)
    if args.check:
        run_check(args.target_dir, args.neo4j_home, args.java_home)
    if args.cleanup_csv:
        cleanup_csv(args.csv_dir)


if __name__ == "__main__":
    main()
