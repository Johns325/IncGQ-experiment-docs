#!/usr/bin/env python3
import argparse
import os
import subprocess
from collections import Counter
from pathlib import Path


NODE_FILES = {
    "Company.csv": "Company",
    "University.csv": "University",
    "Continent.csv": "Continent",
    "Country.csv": "Country",
    "City.csv": "City",
    "Tag.csv": "Tag",
    "TagClass.csv": "TagClass",
    "Forum.csv": "Forum",
    "Comment.csv": "Message:Comment",
    "Post.csv": "Message:Post",
    "Person.csv": "Person",
}

REL_FILES = {
    "City_isPartOf_Country.csv": "IS_PART_OF",
    "Country_isPartOf_Continent.csv": "IS_PART_OF",
    "Comment_hasCreator_Person.csv": "HAS_CREATOR",
    "Comment_hasTag_Tag.csv": "HAS_TAG",
    "Comment_isLocatedIn_Country.csv": "IS_LOCATED_IN",
    "Comment_replyOf_Comment.csv": "REPLY_OF",
    "Comment_replyOf_Post.csv": "REPLY_OF",
    "Company_isLocatedIn_Country.csv": "IS_LOCATED_IN",
    "University_isLocatedIn_City.csv": "IS_LOCATED_IN",
    "Forum_containerOf_Post.csv": "CONTAINER_OF",
    "Forum_hasMember_Person.csv": "HAS_MEMBER",
    "Forum_hasModerator_Person.csv": "HAS_MODERATOR",
    "Forum_hasTag_Tag.csv": "HAS_TAG",
    "Person_hasInterest_Tag.csv": "HAS_INTEREST",
    "Person_isLocatedIn_City.csv": "IS_LOCATED_IN",
    "Person_knows_Person.csv": "KNOWS",
    "Person_likes_Comment.csv": "LIKES",
    "Person_likes_Post.csv": "LIKES",
    "Person_studyAt_University.csv": "STUDY_AT",
    "Person_workAt_Company.csv": "WORK_AT",
    "Post_hasCreator_Person.csv": "HAS_CREATOR",
    "Post_hasTag_Tag.csv": "HAS_TAG",
    "Post_isLocatedIn_Country.csv": "IS_LOCATED_IN",
    "TagClass_isSubclassOf_TagClass.csv": "IS_SUBCLASS_OF",
    "Tag_hasType_TagClass.csv": "HAS_TYPE",
}


def line_count(path: Path) -> int:
    with path.open("rb") as file:
        return sum(1 for _ in file)


def data_rows(path: Path) -> int:
    return max(line_count(path) - 1, 0)


def validate_input_dir(input_dir: Path) -> None:
    expected = set(NODE_FILES) | set(REL_FILES)
    missing = sorted(str(input_dir / file_name) for file_name in expected if not (input_dir / file_name).exists())
    if missing:
        raise SystemExit("Missing expected LSQB CSV files:\n" + "\n".join(missing))


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


def run_import(input_dir: Path, target_dir: Path, neo4j_home: Path, java_home: Path, heap_size: str) -> None:
    validate_input_dir(input_dir)
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
        f"--report-file={target_dir / 'import.report'}",
    ]
    cmd.extend(f"--nodes={labels}={input_dir / file_name}" for file_name, labels in NODE_FILES.items())
    cmd.extend(f"--relationships={rel_type}={input_dir / file_name}" for file_name, rel_type in REL_FILES.items())

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


def validate_counts(input_dir: Path) -> None:
    validate_input_dir(input_dir)
    node_label_counts = Counter()
    rel_type_counts = Counter()

    print("Node input row counts:")
    for file_name, labels in NODE_FILES.items():
        rows = data_rows(input_dir / file_name)
        print(f"  {file_name}: data_rows={rows}")
        for label in labels.split(":"):
            node_label_counts[label] += rows

    print("Relationship input row counts:")
    for file_name, rel_type in REL_FILES.items():
        rows = data_rows(input_dir / file_name)
        print(f"  {file_name}: data_rows={rows}")
        rel_type_counts[rel_type] += rows

    print("Node label counts:")
    for label in sorted(node_label_counts):
        print(f"  {label}: {node_label_counts[label]}")
    print("Relationship type counts:")
    for rel_type in sorted(rel_type_counts):
        print(f"  {rel_type}: {rel_type_counts[rel_type]}")
    print(f"Node input total: {sum(data_rows(input_dir / name) for name in NODE_FILES)}")
    print(f"Relationship input total: {sum(data_rows(input_dir / name) for name in REL_FILES)}")
    print("Count validation passed.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Import LSQB SF1 projected-fk CSVs into Neo4j 5.")
    parser.add_argument("--input-dir", type=Path, required=True, help="Extracted social-network-sf1-projected-fk directory.")
    parser.add_argument("--target-dir", type=Path, required=True)
    parser.add_argument("--neo4j-home", type=Path, required=True)
    parser.add_argument("--java-home", type=Path, required=True)
    parser.add_argument("--heap-size", default="8G")
    parser.add_argument("--skip-import", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--validate-counts", action="store_true", help="Print raw CSV data-row counts and derived label/type counts.")
    args = parser.parse_args()

    if not args.skip_import:
        run_import(args.input_dir, args.target_dir, args.neo4j_home, args.java_home, args.heap_size)
    if args.check:
        run_check(args.target_dir, args.neo4j_home, args.java_home)
    if args.validate_counts:
        validate_counts(args.input_dir)


if __name__ == "__main__":
    main()
