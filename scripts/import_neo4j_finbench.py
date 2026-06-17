#!/usr/bin/env python3
import argparse
import csv
import os
import shutil
import subprocess
import tarfile
from collections import Counter
from pathlib import Path


csv.field_size_limit(1024 * 1024 * 1024)


NODE_FILES = {
    "Person.csv": {
        "label": "Person",
        "group": "Person",
        "columns": [
            ("personId", "id", "ID", "Person"),
            ("personName", "name", "STRING", None),
            ("isBlocked", "isBlocked", "BOOLEAN", None),
            ("createTime", "createTime", "STRING", None),
            ("gender", "gender", "STRING", None),
            ("birthday", "birthday", "STRING", None),
            ("country", "country", "STRING", None),
            ("city", "city", "STRING", None),
        ],
    },
    "Company.csv": {
        "label": "Company",
        "group": "Company",
        "columns": [
            ("companyId", "id", "ID", "Company"),
            ("companyName", "name", "STRING", None),
            ("isBlocked", "isBlocked", "BOOLEAN", None),
            ("createTime", "createTime", "STRING", None),
            ("country", "country", "STRING", None),
            ("city", "city", "STRING", None),
            ("business", "business", "STRING", None),
            ("description", "description", "STRING", None),
            ("url", "url", "STRING", None),
        ],
    },
    "Account.csv": {
        "label": "Account",
        "group": "Account",
        "columns": [
            ("accountId", "id", "ID", "Account"),
            ("createTime", "createTime", "STRING", None),
            ("isBlocked", "isBlocked", "BOOLEAN", None),
            ("accoutType", "type", "STRING", None),
            ("nickname", "nickname", "STRING", None),
            ("phonenum", "phonenum", "STRING", None),
            ("email", "email", "STRING", None),
            ("freqLoginType", "freqLoginType", "STRING", None),
            ("lastLoginTime", "lastLoginTime", "LONG", None),
            ("accountLevel", "accountLevel", "STRING", None),
        ],
    },
    "Loan.csv": {
        "label": "Loan",
        "group": "Loan",
        "columns": [
            ("loanId", "id", "ID", "Loan"),
            ("loanAmount", "loanAmount", "DOUBLE", None),
            ("balance", "balance", "DOUBLE", None),
            ("createTime", "createTime", "STRING", None),
            ("loanUsage", "loanUsage", "STRING", None),
            ("interestRate", "interestRate", "DOUBLE", None),
        ],
    },
    "Medium.csv": {
        "label": "Medium",
        "group": "Medium",
        "columns": [
            ("mediumId", "id", "ID", "Medium"),
            ("mediumType", "type", "STRING", None),
            ("isBlocked", "isBlocked", "BOOLEAN", None),
            ("createTime", "createTime", "STRING", None),
            ("lastLoginTime", "lastLoginTime", "LONG", None),
            ("riskLevel", "riskLevel", "STRING", None),
        ],
    },
}


REL_FILES = {
    "PersonOwnAccount.csv": {
        "type": "own",
        "start_group": "Person",
        "end_group": "Account",
        "columns": [
            ("personId", ":START_ID", "Person"),
            ("accountId", ":END_ID", "Account"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "CompanyOwnAccount.csv": {
        "type": "own",
        "start_group": "Company",
        "end_group": "Account",
        "columns": [
            ("companyId", ":START_ID", "Company"),
            ("accountId", ":END_ID", "Account"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "PersonApplyLoan.csv": {
        "type": "apply",
        "start_group": "Person",
        "end_group": "Loan",
        "columns": [
            ("personId", ":START_ID", "Person"),
            ("loanId", ":END_ID", "Loan"),
            ("createTime", "timestamp", "STRING"),
            ("org", "org", "STRING"),
        ],
    },
    "CompanyApplyLoan.csv": {
        "type": "apply",
        "start_group": "Company",
        "end_group": "Loan",
        "columns": [
            ("companyId", ":START_ID", "Company"),
            ("loanId", ":END_ID", "Loan"),
            ("createTime", "timestamp", "STRING"),
            ("org", "org", "STRING"),
        ],
    },
    "PersonGuaranteePerson.csv": {
        "type": "guarantee",
        "start_group": "Person",
        "end_group": "Person",
        "columns": [
            ("fromId", ":START_ID", "Person"),
            ("toId", ":END_ID", "Person"),
            ("createTime", "timestamp", "STRING"),
            ("relation", "relation", "STRING"),
        ],
    },
    "CompanyGuaranteeCompany.csv": {
        "type": "guarantee",
        "start_group": "Company",
        "end_group": "Company",
        "columns": [
            ("fromId", ":START_ID", "Company"),
            ("toId", ":END_ID", "Company"),
            ("createTime", "timestamp", "STRING"),
            ("relation", "relation", "STRING"),
        ],
    },
    "PersonInvestCompany.csv": {
        "type": "invest",
        "start_group": "Person",
        "end_group": "Company",
        "columns": [
            ("investorId", ":START_ID", "Person"),
            ("companyId", ":END_ID", "Company"),
            ("ratio", "ratio", "DOUBLE"),
            ("ratio", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "CompanyInvestCompany.csv": {
        "type": "invest",
        "start_group": "Company",
        "end_group": "Company",
        "columns": [
            ("investorId", ":START_ID", "Company"),
            ("companyId", ":END_ID", "Company"),
            ("ratio", "ratio", "DOUBLE"),
            ("ratio", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "AccountTransferAccount.csv": {
        "type": "transfer",
        "start_group": "Account",
        "end_group": "Account",
        "columns": [
            ("fromId", ":START_ID", "Account"),
            ("toId", ":END_ID", "Account"),
            ("amount", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
            ("orderNum", "orderNum", "STRING"),
            ("comment", "comment", "STRING"),
            ("payType", "payType", "STRING"),
            ("goodsType", "goodsType", "STRING"),
        ],
    },
    "AccountWithdrawAccount.csv": {
        "type": "withdraw",
        "start_group": "Account",
        "end_group": "Account",
        "columns": [
            ("fromId", ":START_ID", "Account"),
            ("toId", ":END_ID", "Account"),
            ("amount", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "AccountRepayLoan.csv": {
        "type": "repay",
        "start_group": "Account",
        "end_group": "Loan",
        "columns": [
            ("accountId", ":START_ID", "Account"),
            ("loanId", ":END_ID", "Loan"),
            ("amount", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "LoanDepositAccount.csv": {
        "type": "deposit",
        "start_group": "Loan",
        "end_group": "Account",
        "columns": [
            ("loanId", ":START_ID", "Loan"),
            ("accountId", ":END_ID", "Account"),
            ("amount", "amount", "DOUBLE"),
            ("createTime", "timestamp", "STRING"),
        ],
    },
    "MediumSignInAccount.csv": {
        "type": "signIn",
        "start_group": "Medium",
        "end_group": "Account",
        "columns": [
            ("mediumId", ":START_ID", "Medium"),
            ("accountId", ":END_ID", "Account"),
            ("createTime", "timestamp", "STRING"),
            ("location", "location", "STRING"),
        ],
    },
}


def resolve_snapshot_dir(data_dir: Path) -> Path:
    if (data_dir / "snapshot").is_dir():
        return data_dir / "snapshot"
    return data_dir


def extract_archive(archive: Path, extract_dir: Path, overwrite: bool) -> Path:
    if extract_dir.exists():
        if not overwrite:
            raise SystemExit(f"Extract dir already exists: {extract_dir}. Use --overwrite-extract to replace it.")
        shutil.rmtree(extract_dir)
    extract_dir.mkdir(parents=True)
    with tarfile.open(archive) as tar:
        tar.extractall(extract_dir)

    candidates = sorted(path for path in extract_dir.rglob("snapshot") if path.is_dir())
    if len(candidates) != 1:
        found = "\n".join(str(path) for path in candidates) or "(none)"
        raise SystemExit(f"Expected exactly one snapshot directory under {extract_dir}, found:\n{found}")
    return candidates[0]


def typed_node_header(spec: dict) -> list[str]:
    fields = []
    for _src, dst, typ, group in spec["columns"]:
        if typ == "ID":
            fields.append(f":ID({group})")
            fields.append(f"{dst}:LONG")
        else:
            fields.append(f"{dst}:{typ}")
    return fields


def typed_rel_header(spec: dict) -> list[str]:
    fields = []
    for _src, dst, typ in spec["columns"]:
        if dst == ":START_ID":
            fields.append(f":START_ID({typ})")
        elif dst == ":END_ID":
            fields.append(f":END_ID({typ})")
        else:
            fields.append(f"{dst}:{typ}")
    return fields


def transform_csv(src: Path, dst: Path, mappings: list[tuple[str, str, str]]) -> int:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open("r", encoding="utf-8", newline="") as input_file, dst.open("w", encoding="utf-8", newline="") as output_file:
        reader = csv.DictReader(input_file, delimiter="|")
        missing = sorted({src_name for src_name, _dst_name, _typ in mappings if src_name not in reader.fieldnames})
        if missing:
            raise SystemExit(f"{src} is missing expected columns: {', '.join(missing)}")
        writer = csv.writer(output_file, delimiter="|", lineterminator="\n")
        rows = 0
        for row in reader:
            writer.writerow([row[src_name] for src_name, _dst_name, _typ in mappings])
            rows += 1
    return rows


def write_header(path: Path, fields: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.writer(file, delimiter="|", lineterminator="\n")
        writer.writerow(fields)


def require_inputs(snapshot_dir: Path) -> None:
    expected = set(NODE_FILES) | set(REL_FILES)
    missing = sorted(name for name in expected if not (snapshot_dir / name).is_file())
    if missing:
        raise SystemExit("Missing expected FinBench snapshot CSV files:\n" + "\n".join(missing))


def prepare(snapshot_dir: Path, target_dir: Path) -> dict[str, int]:
    require_inputs(snapshot_dir)
    prepared_csv = target_dir / "prepared-csv" / "snapshot"
    prepared_headers = target_dir / "prepared-headers"
    shutil.rmtree(prepared_csv, ignore_errors=True)
    shutil.rmtree(prepared_headers, ignore_errors=True)

    counts = {}
    for filename, spec in NODE_FILES.items():
        write_header(prepared_headers / filename, typed_node_header(spec))
        mappings = []
        for src, dst, typ, _group in spec["columns"]:
            if typ == "ID":
                mappings.append((src, ":ID", "STRING"))
                mappings.append((src, dst, "LONG"))
            else:
                mappings.append((src, dst, typ))
        count = transform_csv(
            snapshot_dir / filename,
            prepared_csv / filename,
            mappings,
        )
        counts[filename] = count

    for filename, spec in REL_FILES.items():
        write_header(prepared_headers / filename, typed_rel_header(spec))
        count = transform_csv(snapshot_dir / filename, prepared_csv / filename, spec["columns"])
        counts[filename] = count

    print(f"Wrote typed headers to {prepared_headers}")
    print(f"Wrote transformed CSV copies to {prepared_csv}")
    return counts


def file_group(target_dir: Path, filename: str) -> str:
    header = target_dir / "prepared-headers" / filename
    data = target_dir / "prepared-csv" / "snapshot" / filename
    missing = [str(path) for path in [header, data] if not path.exists()]
    if missing:
        raise SystemExit("Missing prepared import files:\n" + "\n".join(missing))
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


def run_import(target_dir: Path, neo4j_home: Path, java_home: Path, heap_size: str, verbose: bool) -> None:
    conf_dir = write_config(target_dir)
    cmd = [
        str(neo4j_home / "bin" / "neo4j-admin"),
        "database",
        "import",
        "full",
        "--id-type=STRING",
        "--ignore-empty-strings=true",
        "--bad-tolerance=0",
        "--overwrite-destination=true",
        "--delimiter=|",
        f"--report-file={target_dir / 'import.report'}",
    ]
    if verbose:
        cmd.append("--verbose")
    cmd.extend(f"--nodes={spec['label']}={file_group(target_dir, filename)}" for filename, spec in NODE_FILES.items())
    cmd.extend(f"--relationships={spec['type']}={file_group(target_dir, filename)}" for filename, spec in REL_FILES.items())

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


def csv_record_count(path: Path) -> int:
    with path.open("r", encoding="utf-8", newline="") as file:
        reader = csv.reader(file, delimiter="|")
        try:
            next(reader)
        except StopIteration:
            return 0
        return sum(1 for _row in reader)


def prepared_record_count(path: Path) -> int:
    with path.open("r", encoding="utf-8", newline="") as file:
        return sum(1 for _row in csv.reader(file, delimiter="|"))


def validate_counts(snapshot_dir: Path, target_dir: Path) -> None:
    mismatches = []
    node_counts = Counter()
    rel_counts = Counter()

    print("Node input row counts:")
    for filename, spec in NODE_FILES.items():
        raw_rows = csv_record_count(snapshot_dir / filename)
        prepared_rows = prepared_record_count(target_dir / "prepared-csv" / "snapshot" / filename)
        print(f"  {filename}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((filename, raw_rows, prepared_rows))
        node_counts[spec["label"]] += prepared_rows

    print("Relationship input row counts:")
    for filename, spec in REL_FILES.items():
        raw_rows = csv_record_count(snapshot_dir / filename)
        prepared_rows = prepared_record_count(target_dir / "prepared-csv" / "snapshot" / filename)
        print(f"  {filename}: raw_data_rows={raw_rows} prepared_rows={prepared_rows}")
        if raw_rows != prepared_rows:
            mismatches.append((filename, raw_rows, prepared_rows))
        rel_counts[spec["type"]] += prepared_rows

    print("Node label counts:")
    for label in sorted(node_counts):
        print(f"  {label}: {node_counts[label]}")
    print("Relationship type counts:")
    for rel_type in sorted(rel_counts):
        print(f"  {rel_type}: {rel_counts[rel_type]}")
    print(f"Node input total: {sum(node_counts.values())}")
    print(f"Relationship input total: {sum(rel_counts.values())}")

    if mismatches:
        for filename, raw_rows, prepared_rows in mismatches:
            print(f"Count mismatch: {filename}: raw_data_rows={raw_rows}, prepared_rows={prepared_rows}")
        raise SystemExit(1)
    print("Count validation passed.")


def cleanup_prepared(target_dir: Path) -> None:
    shutil.rmtree(target_dir / "prepared-csv", ignore_errors=True)
    shutil.rmtree(target_dir / "prepared-headers", ignore_errors=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare and import FinBench snapshot CSVs into Neo4j 5.")
    parser.add_argument("--archive", type=Path, help="Optional FinBench tar archive to extract under --extract-dir.")
    parser.add_argument("--extract-dir", type=Path, help="Directory used for a fresh archive extraction.")
    parser.add_argument("--overwrite-extract", action="store_true")
    parser.add_argument("--data-dir", type=Path, help="FinBench directory or snapshot directory. Ignored if --archive is used.")
    parser.add_argument("--target-dir", type=Path, required=True)
    parser.add_argument("--neo4j-home", type=Path, required=True)
    parser.add_argument("--java-home", type=Path, required=True)
    parser.add_argument("--heap-size", default="8G")
    parser.add_argument("--verbose", action="store_true", help="Pass --verbose to neo4j-admin database import full.")
    parser.add_argument("--skip-prepare", action="store_true")
    parser.add_argument("--skip-import", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--validate-counts", action="store_true")
    parser.add_argument("--cleanup-prepared", action="store_true", help="Delete prepared CSV/header copies after import/check/validation.")
    args = parser.parse_args()

    if args.archive:
        if not args.extract_dir:
            raise SystemExit("--extract-dir is required when --archive is used")
        snapshot_dir = extract_archive(args.archive, args.extract_dir, args.overwrite_extract)
    elif args.data_dir:
        snapshot_dir = resolve_snapshot_dir(args.data_dir)
    else:
        raise SystemExit("Either --archive or --data-dir is required")

    if not args.skip_prepare:
        prepare(snapshot_dir, args.target_dir)
    if args.validate_counts:
        validate_counts(snapshot_dir, args.target_dir)
    if not args.skip_import:
        run_import(args.target_dir, args.neo4j_home, args.java_home, args.heap_size, args.verbose)
    if args.check:
        run_check(args.target_dir, args.neo4j_home, args.java_home)
    if args.cleanup_prepared:
        cleanup_prepared(args.target_dir)


if __name__ == "__main__":
    main()
