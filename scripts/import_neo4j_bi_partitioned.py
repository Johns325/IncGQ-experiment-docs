#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
from collections import Counter
from pathlib import Path


NODE_DIRS = {
    "static/Place": ("Place", "Place"),
    "static/Organisation": ("Organisation", "Organisation"),
    "static/TagClass": ("TagClass", "TagClass"),
    "static/Tag": ("Tag", "Tag"),
    "dynamic/Forum": ("Forum", "Forum"),
    "dynamic/Person": ("Person", "Person"),
    "dynamic/Comment": ("Comment", "Message:Comment"),
    "dynamic/Post": ("Post", "Message:Post"),
}

REL_DIRS = {
    "static/Place_isPartOf_Place": ("IS_PART_OF", "Place", "Place"),
    "static/TagClass_isSubclassOf_TagClass": ("IS_SUBCLASS_OF", "TagClass", "TagClass"),
    "static/Organisation_isLocatedIn_Place": ("IS_LOCATED_IN", "Organisation", "Place"),
    "static/Tag_hasType_TagClass": ("HAS_TYPE", "Tag", "TagClass"),
    "dynamic/Comment_hasCreator_Person": ("HAS_CREATOR", "Comment", "Person"),
    "dynamic/Comment_hasTag_Tag": ("HAS_TAG", "Comment", "Tag"),
    "dynamic/Comment_isLocatedIn_Country": ("IS_LOCATED_IN", "Comment", "Place"),
    "dynamic/Comment_replyOf_Comment": ("REPLY_OF", "Comment", "Comment"),
    "dynamic/Comment_replyOf_Post": ("REPLY_OF", "Comment", "Post"),
    "dynamic/Forum_containerOf_Post": ("CONTAINER_OF", "Forum", "Post"),
    "dynamic/Forum_hasMember_Person": ("HAS_MEMBER", "Forum", "Person"),
    "dynamic/Forum_hasModerator_Person": ("HAS_MODERATOR", "Forum", "Person"),
    "dynamic/Forum_hasTag_Tag": ("HAS_TAG", "Forum", "Tag"),
    "dynamic/Person_hasInterest_Tag": ("HAS_INTEREST", "Person", "Tag"),
    "dynamic/Person_isLocatedIn_City": ("IS_LOCATED_IN", "Person", "Place"),
    "dynamic/Person_knows_Person": ("KNOWS", "Person", "Person"),
    "dynamic/Person_likes_Comment": ("LIKES", "Person", "Comment"),
    "dynamic/Person_likes_Post": ("LIKES", "Person", "Post"),
    "dynamic/Person_studyAt_University": ("STUDY_AT", "Person", "Organisation"),
    "dynamic/Person_workAt_Company": ("WORK_AT", "Person", "Organisation"),
    "dynamic/Post_hasCreator_Person": ("HAS_CREATOR", "Post", "Person"),
    "dynamic/Post_hasTag_Tag": ("HAS_TAG", "Post", "Tag"),
    "dynamic/Post_isLocatedIn_Country": ("IS_LOCATED_IN", "Post", "Place"),
}

TYPE_MAP = {
    "creationDate": "DATETIME",
    "birthday": "DATE",
    "length": "LONG",
    "classYear": "LONG",
    "workFrom": "LONG",
    "language": "STRING[]",
    "email": "STRING[]",
}

RENAME_MAP = {"language": "speaks"}
LABEL_COLUMNS = {("static/Place", "type"), ("static/Organisation", "type")}


def first_part_csv(directory: Path) -> Path:
    try:
        return next(iter(sorted(directory.glob("part-*.csv*"))))
    except StopIteration as exc:
        raise SystemExit(f"No part CSV files found in {directory}") from exc


def read_header(path: Path) -> list[str]:
    with path.open("rt", encoding="utf-8", newline="") as file:
        return file.readline().rstrip("\n\r").split("|")


def node_header(rel_dir: str, group: str, columns: list[str]) -> str:
    fields = []
    for column in columns:
        if (rel_dir, column) in LABEL_COLUMNS:
            fields.append(":LABEL")
        elif column == "id":
            fields.append(f"id:ID({group})")
        else:
            name = RENAME_MAP.get(column, column)
            fields.append(f"{name}:{TYPE_MAP.get(column, 'STRING')}")
    return "|".join(fields) + "\n"


def rel_header(start_group: str, end_group: str, columns: list[str]) -> str:
    fields = [f":START_ID({start_group})", f":END_ID({end_group})"]
    fields.extend(f"{column}:{TYPE_MAP.get(column, 'STRING')}" for column in columns[2:])
    return "|".join(fields) + "\n"


def copy_without_header(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open("rb") as input_file, dst.open("wb") as output_file:
        input_file.readline()
        shutil.copyfileobj(input_file, output_file, length=1024 * 1024)


def prepare(data_dir: Path, target_dir: Path) -> None:
    prepared_csv = target_dir / "prepared-csv" / "initial_snapshot"
    prepared_headers = target_dir / "prepared-headers"

    expected = set(NODE_DIRS) | set(REL_DIRS)
    actual = {str(path.relative_to(data_dir)) for path in data_dir.glob("*/*") if path.is_dir()}
    missing = sorted(expected - actual)
    if missing:
        raise SystemExit("Missing expected CSV directories:\n" + "\n".join(missing))

    for rel_dir, (group, _labels) in NODE_DIRS.items():
        columns = read_header(first_part_csv(data_dir / rel_dir))
        header_path = prepared_headers / rel_dir / "_header.csv"
        header_path.parent.mkdir(parents=True, exist_ok=True)
        header_path.write_text(node_header(rel_dir, group, columns), encoding="utf-8")

    for rel_dir, (_rel_type, start_group, end_group) in REL_DIRS.items():
        columns = read_header(first_part_csv(data_dir / rel_dir))
        header_path = prepared_headers / rel_dir / "_header.csv"
        header_path.parent.mkdir(parents=True, exist_ok=True)
        header_path.write_text(rel_header(start_group, end_group, columns), encoding="utf-8")

    copied = 0
    for src in sorted(data_dir.glob("*/*/part-*.csv*")):
        copy_without_header(src, prepared_csv / src.relative_to(data_dir))
        copied += 1
    print(f"Wrote {copied} headerless CSV files to {prepared_csv}")
    print(f"Wrote typed headers to {prepared_headers}")


def file_group(target_dir: Path, rel_dir: str) -> str:
    header = target_dir / "prepared-headers" / rel_dir / "_header.csv"
    data_files = sorted((target_dir / "prepared-csv" / "initial_snapshot" / rel_dir).glob("part-*.csv*"))
    files = [header, *data_files]
    missing = [str(path) for path in files if not path.exists()]
    if missing:
        raise SystemExit("Missing prepared import files:\n" + "\n".join(missing))
    return ",".join(str(path) for path in files)


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


def run_import(target_dir: Path, neo4j_home: Path, java_home: Path, heap_size: str) -> None:
    conf_dir = write_config(target_dir)
    neo4j_admin = neo4j_home / "bin" / "neo4j-admin"
    cmd = [
        str(neo4j_admin),
        "database",
        "import",
        "full",
        "--id-type=INTEGER",
        "--ignore-empty-strings=true",
        "--bad-tolerance=0",
        "--overwrite-destination=true",
        "--delimiter=|",
        "--array-delimiter=;",
        f"--report-file={target_dir / 'import.report'}",
    ]
    cmd.extend(f"--nodes={labels}={file_group(target_dir, rel_dir)}" for rel_dir, (_group, labels) in NODE_DIRS.items())
    cmd.extend(f"--relationships={rel_type}={file_group(target_dir, rel_dir)}" for rel_dir, (rel_type, _start, _end) in REL_DIRS.items())

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


def line_count(path: Path) -> int:
    with path.open("rb") as file:
        return sum(1 for _ in file)


def label_indices(header_path: Path) -> list[int]:
    fields = header_path.read_text(encoding="utf-8").strip().split("|")
    return [idx for idx, field in enumerate(fields) if field == ":LABEL"]


def add_dynamic_label_counts(counts: Counter, data_files: list[Path], indices: list[int]) -> None:
    if not indices:
        return
    for data_file in data_files:
        with data_file.open(encoding="utf-8") as file:
            for line in file:
                columns = line.rstrip("\n").split("|")
                for idx in indices:
                    if idx < len(columns) and columns[idx]:
                        for label in columns[idx].split(";"):
                            if label:
                                counts[label] += 1


def validate_counts(data_dir: Path, target_dir: Path) -> None:
    prepared_csv = target_dir / "prepared-csv" / "initial_snapshot"
    prepared_headers = target_dir / "prepared-headers"
    mismatches = []
    node_label_counts = Counter()
    node_table_counts = {}

    print("Node input row counts:")
    for rel_dir, (_group, labels) in NODE_DIRS.items():
        raw_files = sorted((data_dir / rel_dir).glob("part-*.csv*"))
        prepared_files = sorted((prepared_csv / rel_dir).glob("part-*.csv*"))
        raw_rows = sum(max(line_count(path) - 1, 0) for path in raw_files)
        prepared_rows = sum(line_count(path) for path in prepared_files)
        print(f"  {rel_dir}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((rel_dir, raw_rows, prepared_rows))
        node_table_counts[rel_dir] = prepared_rows
        for label in labels.split(":"):
            node_label_counts[label] += prepared_rows
        add_dynamic_label_counts(node_label_counts, prepared_files, label_indices(prepared_headers / rel_dir / "_header.csv"))

    rel_type_counts = Counter()
    rel_table_counts = {}
    print("Relationship input row counts:")
    for rel_dir, (rel_type, _start_group, _end_group) in REL_DIRS.items():
        raw_files = sorted((data_dir / rel_dir).glob("part-*.csv*"))
        prepared_files = sorted((prepared_csv / rel_dir).glob("part-*.csv*"))
        raw_rows = sum(max(line_count(path) - 1, 0) for path in raw_files)
        prepared_rows = sum(line_count(path) for path in prepared_files)
        print(f"  {rel_dir}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((rel_dir, raw_rows, prepared_rows))
        rel_table_counts[rel_dir] = prepared_rows
        rel_type_counts[rel_type] += prepared_rows

    print("Node label counts:")
    for label in sorted(node_label_counts):
        print(f"  {label}: {node_label_counts[label]}")
    print("Relationship type counts:")
    for rel_type in sorted(rel_type_counts):
        print(f"  {rel_type}: {rel_type_counts[rel_type]}")
    print(f"Node input total: {sum(node_table_counts.values())}")
    print(f"Relationship input total: {sum(rel_table_counts.values())}")

    if mismatches:
        for name, raw_rows, prepared_rows in mismatches:
            print(f"Count mismatch: {name}: raw_data_rows={raw_rows}, prepared_rows={prepared_rows}")
        raise SystemExit(1)
    print("Count validation passed.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare and import partitioned LDBC SNB BI CSVs into Neo4j 5.")
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--target-dir", type=Path, required=True)
    parser.add_argument("--neo4j-home", type=Path, required=True)
    parser.add_argument("--java-home", type=Path, required=True)
    parser.add_argument("--heap-size", default="8G")
    parser.add_argument("--skip-prepare", action="store_true")
    parser.add_argument("--skip-import", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--validate-counts", action="store_true", help="Compare raw CSV data rows with prepared CSV rows and print label/type counts.")
    args = parser.parse_args()

    if not args.skip_prepare:
        prepare(args.data_dir, args.target_dir)
    if not args.skip_import:
        run_import(args.target_dir, args.neo4j_home, args.java_home, args.heap_size)
    if args.check:
        run_check(args.target_dir, args.neo4j_home, args.java_home)
    if args.validate_counts:
        validate_counts(args.data_dir, args.target_dir)


if __name__ == "__main__":
    main()
