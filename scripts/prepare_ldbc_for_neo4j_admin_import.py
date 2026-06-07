#!/usr/bin/env python3
import argparse
import csv
from datetime import datetime, timezone
from pathlib import Path

NODE_GROUPS = {
    "place_0_0.csv": "Place",
    "organisation_0_0.csv": "Organisation",
    "tagclass_0_0.csv": "TagClass",
    "tag_0_0.csv": "Tag",
    "comment_0_0.csv": "Comment",
    "forum_0_0.csv": "Forum",
    "person_0_0.csv": "Person",
    "post_0_0.csv": "Post",
}

REL_GROUPS = {
    "place_isPartOf_place_0_0.csv": ("Place", "Place"),
    "tagclass_isSubclassOf_tagclass_0_0.csv": ("TagClass", "TagClass"),
    "organisation_isLocatedIn_place_0_0.csv": ("Organisation", "Place"),
    "tag_hasType_tagclass_0_0.csv": ("Tag", "TagClass"),
    "comment_hasCreator_person_0_0.csv": ("Comment", "Person"),
    "comment_isLocatedIn_place_0_0.csv": ("Comment", "Place"),
    "comment_replyOf_comment_0_0.csv": ("Comment", "Comment"),
    "comment_replyOf_post_0_0.csv": ("Comment", "Post"),
    "forum_containerOf_post_0_0.csv": ("Forum", "Post"),
    "forum_hasMember_person_0_0.csv": ("Forum", "Person"),
    "forum_hasModerator_person_0_0.csv": ("Forum", "Person"),
    "forum_hasTag_tag_0_0.csv": ("Forum", "Tag"),
    "person_hasInterest_tag_0_0.csv": ("Person", "Tag"),
    "person_isLocatedIn_place_0_0.csv": ("Person", "Place"),
    "person_knows_person_0_0.csv": ("Person", "Person"),
    "person_likes_comment_0_0.csv": ("Person", "Comment"),
    "person_likes_post_0_0.csv": ("Person", "Post"),
    "post_hasCreator_person_0_0.csv": ("Post", "Person"),
    "comment_hasTag_tag_0_0.csv": ("Comment", "Tag"),
    "post_hasTag_tag_0_0.csv": ("Post", "Tag"),
    "post_isLocatedIn_place_0_0.csv": ("Post", "Place"),
    "person_studyAt_organisation_0_0.csv": ("Person", "Organisation"),
    "person_workAt_organisation_0_0.csv": ("Person", "Organisation"),
}

NUMERIC_TYPES = {
    "id": "long",
    "creationDate": "long",
    "deletionDate": "long",
    "birthday": "long",
    "joinDate": "long",
    "length": "int",
    "classYear": "int",
    "workFrom": "int",
}

EPOCH_MILLIS_COLUMNS = {"creationDate", "deletionDate", "birthday", "joinDate"}


def property_name(header):
    return header.split(":", 1)[0].rsplit(".", 1)[-1]


def typed_property(header):
    name = property_name(header)
    value_type = NUMERIC_TYPES.get(name)
    return f"{name}:{value_type}" if value_type else name


def to_epoch_millis(value):
    if value == "" or value.lstrip("-").isdigit():
        return value

    normalized = value[:-1] + "+0000" if value.endswith("Z") else value
    for fmt in ("%Y-%m-%dT%H:%M:%S.%f%z", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(normalized, fmt)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            return str(int(dt.timestamp() * 1000))
        except ValueError:
            continue
    raise ValueError(f"Cannot convert date/time value to epoch milliseconds: {value}")


def convert_value(name, value):
    return to_epoch_millis(value) if name in EPOCH_MILLIS_COLUMNS else value


def converted_row(names, row):
    return [convert_value(name, value) for name, value in zip(names, row)]


def convert_node(src, data_dst, header_dst, group):
    header_dst.parent.mkdir(parents=True, exist_ok=True)
    data_dst.parent.mkdir(parents=True, exist_ok=True)

    with src.open(newline="", encoding="utf-8") as input_file, data_dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        header = next(reader)
        names = [property_name(column) for column in header]

        header_dst.write_text(
            "|".join([f":ID({group})", "id:long", *[typed_property(column) for column in header[1:]]]) + "\n",
            encoding="utf-8",
        )

        for row in reader:
            if row:
                converted = converted_row(names, row)
                writer.writerow([converted[0], converted[0], *converted[1:]])


def convert_relationship(src, data_dst, header_dst, start_group, end_group):
    header_dst.parent.mkdir(parents=True, exist_ok=True)
    data_dst.parent.mkdir(parents=True, exist_ok=True)

    with src.open(newline="", encoding="utf-8") as input_file, data_dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        header = next(reader)
        names = [property_name(column) for column in header]

        header_dst.write_text(
            "|".join([
                f":START_ID({start_group})",
                f":END_ID({end_group})",
                *[typed_property(column) for column in header[2:]],
            ]) + "\n",
            encoding="utf-8",
        )

        for row in reader:
            if row:
                writer.writerow(converted_row(names, row))


def main():
    parser = argparse.ArgumentParser(description="Prepare raw flat LDBC CSV files for Neo4j admin import.")
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("data_dir", type=Path, help="Destination for headerless CSV data files.")
    parser.add_argument("header_dir", type=Path, help="Destination for Neo4j admin import header files.")
    args = parser.parse_args()

    args.data_dir.mkdir(parents=True, exist_ok=True)
    args.header_dir.mkdir(parents=True, exist_ok=True)

    missing = []
    for file_name, group in NODE_GROUPS.items():
        src = args.input_dir / file_name
        if src.exists():
            convert_node(src, args.data_dir / file_name, args.header_dir / file_name, group)
        else:
            missing.append(file_name)

    for file_name, (start_group, end_group) in REL_GROUPS.items():
        src = args.input_dir / file_name
        if src.exists():
            convert_relationship(src, args.data_dir / file_name, args.header_dir / file_name, start_group, end_group)
        else:
            missing.append(file_name)

    if missing:
        print("Missing expected files:")
        for file_name in missing:
            print(f"  {file_name}")
        raise SystemExit(1)

    print(f"Wrote headerless LDBC CSV data into {args.data_dir}")
    print(f"Wrote Neo4j admin import headers into {args.header_dir}")


if __name__ == "__main__":
    main()
