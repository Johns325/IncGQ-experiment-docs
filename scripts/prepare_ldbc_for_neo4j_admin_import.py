#!/usr/bin/env python3
import argparse
import csv
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


def property_name(header):
    name = header.split(":", 1)[0]
    return name.rsplit(".", 1)[-1]


def typed_property(header):
    name = property_name(header)
    value_type = NUMERIC_TYPES.get(name)
    if value_type:
        return f"{name}:{value_type}"
    return name


def convert_node(src, data_dst, header_dst, group):
    header_dst.parent.mkdir(parents=True, exist_ok=True)
    data_dst.parent.mkdir(parents=True, exist_ok=True)

    with src.open(newline="", encoding="utf-8") as input_file, data_dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")

        header = next(reader)
        header_dst.write_text(
            "|".join([f":ID({group})", "id:long", *[typed_property(column) for column in header[1:]]]) + "\n",
            encoding="utf-8",
        )

        for row in reader:
            if not row:
                continue
            writer.writerow([row[0], row[0], *row[1:]])


def convert_relationship(src, data_dst, header_dst, start_group, end_group):
    header_dst.parent.mkdir(parents=True, exist_ok=True)
    data_dst.parent.mkdir(parents=True, exist_ok=True)

    with src.open(newline="", encoding="utf-8") as input_file, data_dst.open("w", newline="", encoding="utf-8") as output_file:
        reader = csv.reader(input_file, delimiter="|")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")

        header = next(reader)
        header_dst.write_text(
            "|".join([
                f":START_ID({start_group})",
                f":END_ID({end_group})",
                *[typed_property(column) for column in header[2:]],
            ]) + "\n",
            encoding="utf-8",
        )

        for row in reader:
            if not row:
                continue
            writer.writerow(row)


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
        if not src.exists():
            missing.append(file_name)
            continue
        convert_node(src, args.data_dir / file_name, args.header_dir / file_name, group)

    for file_name, (start_group, end_group) in REL_GROUPS.items():
        src = args.input_dir / file_name
        if not src.exists():
            missing.append(file_name)
            continue
        convert_relationship(src, args.data_dir / file_name, args.header_dir / file_name, start_group, end_group)

    if missing:
        print("Missing expected files:")
        for file_name in missing:
            print(f"  {file_name}")
        raise SystemExit(1)

    print(f"Wrote headerless LDBC CSV data into {args.data_dir}")
    print(f"Wrote Neo4j admin import headers into {args.header_dir}")


if __name__ == "__main__":
    main()
