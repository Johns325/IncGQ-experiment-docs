#!/usr/bin/env python3
import argparse
import csv
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path


NODE_DIRS = {
    "static/Place": ("Place", "Place"),
    "static/Organisation": ("Organisation", "Organisation"),
    "static/TagClass": ("TagClass", "TagClass"),
    "static/Tag": ("Tag", "Tag"),
    "dynamic/Forum": ("Forum", "Forum"),
    "dynamic/Person": ("Person", "Person"),
    "dynamic/Comment": ("Comment", "Comment:Message"),
    "dynamic/Post": ("Post", "Post:Message"),
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

NUMERIC_TYPES = {
    "id": "long",
    "creationDate": "long",
    "deletionDate": "long",
    "birthday": "long",
    "joinDate": "long",
    "length": "long",
    "classYear": "long",
    "workFrom": "long",
}
EPOCH_MILLIS_COLUMNS = {"creationDate", "deletionDate", "birthday", "joinDate"}
LABEL_COLUMNS = {("static/Place", "type"), ("static/Organisation", "type")}


def part_files(directory: Path) -> list[Path]:
    files = sorted(directory.glob("part-*.csv*"))
    if not files:
        raise SystemExit(f"No part CSV files found in {directory}")
    return files


def to_epoch_millis(value: str) -> str:
    if value == "" or value.lstrip("-").isdigit():
        return value
    normalized = value[:-1] + "+00:00" if value.endswith("Z") else value
    try:
        if "T" in normalized:
            dt = datetime.fromisoformat(normalized)
        else:
            dt = datetime.fromisoformat(normalized).replace(tzinfo=timezone.utc)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return str(int(dt.timestamp() * 1000))
    except ValueError as exc:
        raise ValueError(f"Cannot convert date/time value to epoch milliseconds: {value}") from exc


def typed_property(column: str) -> str:
    value_type = NUMERIC_TYPES.get(column)
    return f"{column}:{value_type}" if value_type else column


def converted_row(columns: list[str], row: list[str]) -> list[str]:
    out = []
    for column, value in zip(columns, row):
        out.append(to_epoch_millis(value) if column in EPOCH_MILLIS_COLUMNS else value)
    return out


def read_header(path: Path) -> list[str]:
    with path.open(newline="", encoding="utf-8") as file:
        return next(csv.reader(file, delimiter="|"))


def write_node_header(rel_dir: str, group: str, columns: list[str], dst: Path) -> None:
    fields = [f":ID({group})", "id:long"]
    for column in columns[1:]:
        fields.append(":LABEL" if (rel_dir, column) in LABEL_COLUMNS else typed_property(column))
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("|".join(fields) + "\n", encoding="utf-8")


def write_rel_header(start_group: str, end_group: str, columns: list[str], dst: Path) -> None:
    fields = [f":START_ID({start_group})", f":END_ID({end_group})"]
    fields.extend(typed_property(column) for column in columns[2:])
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("|".join(fields) + "\n", encoding="utf-8")


def convert_node(rel_dir: str, src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open(newline="", encoding="utf-8") as input_file, dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        columns = next(reader)
        for row in reader:
            if row:
                converted = converted_row(columns, row)
                writer.writerow([converted[0], converted[0], *converted[1:]])


def convert_relationship(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open(newline="", encoding="utf-8") as input_file, dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        columns = next(reader)
        for row in reader:
            if row:
                writer.writerow(converted_row(columns, row))


def prepare(data_dir: Path, target_dir: Path) -> None:
    prepared_csv = target_dir / "prepared-csv" / "initial_snapshot"
    prepared_headers = target_dir / "prepared-headers"

    expected = set(NODE_DIRS) | set(REL_DIRS)
    actual = {str(path.relative_to(data_dir)) for path in data_dir.glob("*/*") if path.is_dir()}
    missing = sorted(expected - actual)
    if missing:
        raise SystemExit("Missing expected CSV directories:\n" + "\n".join(missing))

    converted = 0
    for rel_dir, (group, _labels) in NODE_DIRS.items():
        files = part_files(data_dir / rel_dir)
        write_node_header(rel_dir, group, read_header(files[0]), prepared_headers / rel_dir / "_header.csv")
        for src in files:
            convert_node(rel_dir, src, prepared_csv / rel_dir / src.name)
            converted += 1

    for rel_dir, (_rel_type, start_group, end_group) in REL_DIRS.items():
        files = part_files(data_dir / rel_dir)
        write_rel_header(start_group, end_group, read_header(files[0]), prepared_headers / rel_dir / "_header.csv")
        for src in files:
            convert_relationship(src, prepared_csv / rel_dir / src.name)
            converted += 1

    print(f"Wrote {converted} converted CSV files to {prepared_csv}")
    print(f"Wrote G-View typed headers to {prepared_headers}")


def file_group(target_dir: Path, rel_dir: str) -> str:
    header = target_dir / "prepared-headers" / rel_dir / "_header.csv"
    data_files = sorted((target_dir / "prepared-csv" / "initial_snapshot" / rel_dir).glob("part-*.csv"))
    files = [header, *data_files]
    missing = [str(path) for path in files if not path.exists()]
    if missing:
        raise SystemExit("Missing prepared import files:\n" + "\n".join(missing))
    return ",".join(str(path.relative_to(target_dir)) for path in files)


def write_config(target_dir: Path) -> Path:
    conf_dir = target_dir / "conf"
    conf_dir.mkdir(parents=True, exist_ok=True)
    (target_dir / "logs").mkdir(parents=True, exist_ok=True)
    (target_dir / "data").mkdir(parents=True, exist_ok=True)
    (target_dir / "plugins").mkdir(parents=True, exist_ok=True)
    (conf_dir / "neo4j.conf").write_text(
        "\n".join(
            [
                "server.default_listen_address=127.0.0.1",
                "server.bolt.enabled=false",
                "server.http.enabled=false",
                "dbms.security.auth_enabled=false",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return conf_dir


def run_import(target_dir: Path, gdb_view_home: Path) -> None:
    conf_dir = write_config(target_dir)
    cmd = [
        "java",
        "-cp",
        str(gdb_view_home / "lib2" / "*"),
        "org.neo4j.cli.AdminTool",
        "database",
        "import",
        "full",
        "--overwrite-destination=true",
        "--skip-bad-relationships=true",
        "--skip-duplicate-nodes=true",
        "--bad-tolerance=1000000000",
        "--id-type=INTEGER",
        "--delimiter=|",
    ]
    cmd.extend(f"--nodes={labels}={file_group(target_dir, rel_dir)}" for rel_dir, (_group, labels) in NODE_DIRS.items())
    cmd.extend(f"--relationships={rel_type}={file_group(target_dir, rel_dir)}" for rel_dir, (rel_type, _start, _end) in REL_DIRS.items())
    cmd.append("neo4j")

    env = os.environ.copy()
    env["NEO4J_HOME"] = str(target_dir)
    env["NEO4J_CONF"] = str(conf_dir)
    subprocess.run(cmd, env=env, cwd=target_dir, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare and import LDBC SNB BI partitioned CSVs for G-View.")
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--target-dir", type=Path, required=True)
    parser.add_argument("--gdb-view-home", type=Path, required=True)
    parser.add_argument("--skip-prepare", action="store_true")
    parser.add_argument("--skip-import", action="store_true")
    args = parser.parse_args()

    if not args.skip_prepare:
        prepare(args.data_dir, args.target_dir)
    if not args.skip_import:
        run_import(args.target_dir, args.gdb_view_home)


if __name__ == "__main__":
    main()
