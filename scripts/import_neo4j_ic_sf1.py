#!/usr/bin/env python3
import argparse
import csv
import os
import subprocess
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path


NODE_FILES = {
    "static/place_0_0.csv": ("Place", "Place"),
    "static/organisation_0_0.csv": ("Organisation", "Organisation"),
    "static/tagclass_0_0.csv": ("TagClass", "TagClass"),
    "static/tag_0_0.csv": ("Tag", "Tag"),
    "dynamic/person_0_0.csv": ("Person", "Person"),
    "dynamic/forum_0_0.csv": ("Forum", "Forum"),
    "dynamic/post_0_0.csv": ("Post", "Message:Post"),
    "dynamic/comment_0_0.csv": ("Comment", "Message:Comment"),
}

REL_FILES = {
    "static/place_isPartOf_place_0_0.csv": ("IS_PART_OF", "Place", "Place"),
    "static/tagclass_isSubclassOf_tagclass_0_0.csv": ("IS_SUBCLASS_OF", "TagClass", "TagClass"),
    "static/organisation_isLocatedIn_place_0_0.csv": ("IS_LOCATED_IN", "Organisation", "Place"),
    "static/tag_hasType_tagclass_0_0.csv": ("HAS_TYPE", "Tag", "TagClass"),
    "dynamic/person_isLocatedIn_place_0_0.csv": ("IS_LOCATED_IN", "Person", "Place"),
    "dynamic/person_hasInterest_tag_0_0.csv": ("HAS_INTEREST", "Person", "Tag"),
    "dynamic/person_workAt_organisation_0_0.csv": ("WORK_AT", "Person", "Organisation"),
    "dynamic/person_studyAt_organisation_0_0.csv": ("STUDY_AT", "Person", "Organisation"),
    "dynamic/person_knows_person_0_0.csv": ("KNOWS", "Person", "Person"),
    "dynamic/forum_containerOf_post_0_0.csv": ("CONTAINER_OF", "Forum", "Post"),
    "dynamic/forum_hasMember_person_0_0.csv": ("HAS_MEMBER", "Forum", "Person"),
    "dynamic/forum_hasModerator_person_0_0.csv": ("HAS_MODERATOR", "Forum", "Person"),
    "dynamic/forum_hasTag_tag_0_0.csv": ("HAS_TAG", "Forum", "Tag"),
    "dynamic/person_likes_post_0_0.csv": ("LIKES", "Person", "Post"),
    "dynamic/person_likes_comment_0_0.csv": ("LIKES", "Person", "Comment"),
    "dynamic/post_hasCreator_person_0_0.csv": ("HAS_CREATOR", "Post", "Person"),
    "dynamic/post_hasTag_tag_0_0.csv": ("HAS_TAG", "Post", "Tag"),
    "dynamic/post_isLocatedIn_place_0_0.csv": ("IS_LOCATED_IN", "Post", "Place"),
    "dynamic/comment_hasCreator_person_0_0.csv": ("HAS_CREATOR", "Comment", "Person"),
    "dynamic/comment_hasTag_tag_0_0.csv": ("HAS_TAG", "Comment", "Tag"),
    "dynamic/comment_isLocatedIn_place_0_0.csv": ("IS_LOCATED_IN", "Comment", "Place"),
    "dynamic/comment_replyOf_post_0_0.csv": ("REPLY_OF", "Comment", "Post"),
    "dynamic/comment_replyOf_comment_0_0.csv": ("REPLY_OF", "Comment", "Comment"),
}

EPOCH_MILLIS_COLUMNS = {"birthday", "creationDate", "joinDate"}
LONG_COLUMNS = {"birthday", "creationDate", "joinDate", "length", "classYear", "workFrom"}
ARRAY_COLUMNS = {"language", "email"}
RENAME_COLUMNS = {"language": "speaks"}
LABEL_COLUMNS = {("static/place_0_0.csv", "type"), ("static/organisation_0_0.csv", "type")}


def property_name(header: str) -> str:
    return header.split(":", 1)[0].rsplit(".", 1)[-1]


def label_value(value: str) -> str:
    return value[:1].upper() + value[1:] if value else value


def to_epoch_millis(value: str) -> str:
    if value == "" or value.lstrip("-").isdigit():
        return value

    normalized = value
    if value.endswith("Z"):
        normalized = value[:-1] + "+0000"

    for fmt in ("%Y-%m-%dT%H:%M:%S.%f%z", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(normalized, fmt)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            return str(int(dt.timestamp() * 1000))
        except ValueError:
            continue
    raise ValueError(f"Cannot parse date/time value: {value}")


def convert_value(file_name: str, column: str, value: str) -> str:
    name = property_name(column)
    if (file_name, name) in LABEL_COLUMNS:
        return label_value(value)
    if name in EPOCH_MILLIS_COLUMNS:
        return to_epoch_millis(value)
    return value


def property_header(column: str) -> str:
    name = property_name(column)
    output_name = RENAME_COLUMNS.get(name, name)
    if name in LONG_COLUMNS:
        return f"{output_name}:LONG"
    if name in ARRAY_COLUMNS:
        return f"{output_name}:STRING[]"
    return f"{output_name}:STRING"


def node_header(file_name: str, group: str, columns: list[str]) -> str:
    fields = []
    for column in columns:
        name = property_name(column)
        if (file_name, name) in LABEL_COLUMNS:
            fields.append(":LABEL")
        elif name == "id":
            fields.append(f"id:ID({group})")
        else:
            fields.append(property_header(column))
    return "|".join(fields) + "\n"


def rel_header(start_group: str, end_group: str, columns: list[str]) -> str:
    fields = [f":START_ID({start_group})", f":END_ID({end_group})"]
    fields.extend(property_header(column) for column in columns[2:])
    return "|".join(fields) + "\n"


def convert_csv(src: Path, dst: Path, file_name: str) -> list[str]:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open(newline="", encoding="utf-8") as input_file, dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        header = next(reader)
        for row in reader:
            if row:
                writer.writerow([convert_value(file_name, column, value) for column, value in zip(header, row)])
        return header


def prepare(input_dir: Path, target_dir: Path) -> None:
    prepared_csv = target_dir / "prepared-csv"
    prepared_headers = target_dir / "prepared-headers"

    expected = set(NODE_FILES) | set(REL_FILES)
    missing = sorted(str(input_dir / file_name) for file_name in expected if not (input_dir / file_name).exists())
    if missing:
        raise SystemExit("Missing expected IC CSV files:\n" + "\n".join(missing))

    for file_name, (group, _labels) in NODE_FILES.items():
        header = convert_csv(input_dir / file_name, prepared_csv / file_name, file_name)
        header_path = prepared_headers / file_name
        header_path.parent.mkdir(parents=True, exist_ok=True)
        header_path.write_text(node_header(file_name, group, header), encoding="utf-8")

    for file_name, (_rel_type, start_group, end_group) in REL_FILES.items():
        header = convert_csv(input_dir / file_name, prepared_csv / file_name, file_name)
        header_path = prepared_headers / file_name
        header_path.parent.mkdir(parents=True, exist_ok=True)
        header_path.write_text(rel_header(start_group, end_group, header), encoding="utf-8")

    print(f"Wrote prepared CSV files to {prepared_csv}")
    print(f"Wrote typed headers to {prepared_headers}")


def file_group(target_dir: Path, file_name: str) -> str:
    header = target_dir / "prepared-headers" / file_name
    data = target_dir / "prepared-csv" / file_name
    return f"{header},{data}"


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
    cmd = [
        str(neo4j_home / "bin" / "neo4j-admin"),
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
    cmd.extend(f"--nodes={labels}={file_group(target_dir, file_name)}" for file_name, (_group, labels) in NODE_FILES.items())
    cmd.extend(f"--relationships={rel_type}={file_group(target_dir, file_name)}" for file_name, (rel_type, _start, _end) in REL_FILES.items())

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


def add_dynamic_label_counts(counts: Counter, data_file: Path, indices: list[int]) -> None:
    if not indices:
        return
    with data_file.open(encoding="utf-8") as file:
        for line in file:
            columns = line.rstrip("\n").split("|")
            for idx in indices:
                if idx < len(columns) and columns[idx]:
                    for label in columns[idx].split(";"):
                        if label:
                            counts[label] += 1


def validate_counts(input_dir: Path, target_dir: Path) -> None:
    prepared_csv = target_dir / "prepared-csv"
    prepared_headers = target_dir / "prepared-headers"
    mismatches = []
    node_label_counts = Counter()
    node_table_counts = {}

    print("Node input row counts:")
    for file_name, (_group, labels) in NODE_FILES.items():
        raw_rows = max(line_count(input_dir / file_name) - 1, 0)
        prepared_rows = line_count(prepared_csv / file_name)
        print(f"  {file_name}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((file_name, raw_rows, prepared_rows))
        node_table_counts[file_name] = prepared_rows
        for label in labels.split(":"):
            node_label_counts[label] += prepared_rows
        add_dynamic_label_counts(node_label_counts, prepared_csv / file_name, label_indices(prepared_headers / file_name))

    rel_type_counts = Counter()
    rel_table_counts = {}
    print("Relationship input row counts:")
    for file_name, (rel_type, _start_group, _end_group) in REL_FILES.items():
        raw_rows = max(line_count(input_dir / file_name) - 1, 0)
        prepared_rows = line_count(prepared_csv / file_name)
        print(f"  {file_name}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((file_name, raw_rows, prepared_rows))
        rel_table_counts[file_name] = prepared_rows
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
    parser = argparse.ArgumentParser(description="Prepare and import LDBC SNB IC SF1 CSVs into Neo4j 5.")
    parser.add_argument("--input-dir", type=Path, required=True, help="Extracted social_network-sf1-CsvComposite-StringDateFormatter directory.")
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
        prepare(args.input_dir, args.target_dir)
    if not args.skip_import:
        run_import(args.target_dir, args.neo4j_home, args.java_home, args.heap_size)
    if args.check:
        run_check(args.target_dir, args.neo4j_home, args.java_home)
    if args.validate_counts:
        validate_counts(args.input_dir, args.target_dir)


if __name__ == "__main__":
    main()
