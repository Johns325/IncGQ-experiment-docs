#!/usr/bin/env python3
"""Sample benchmark parameter files for BI, IC, and FinBench workloads."""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from dataclasses import dataclass
from pathlib import Path


DEFAULT_OUTPUT_ROOT = Path("/mnt/data/sampled_parameters")


@dataclass(frozen=True)
class DatasetConfig:
    name: str
    input_dir: Path
    output_dir: Path
    file_pattern: str
    header_mode: str
    query_prefix: str


DATASETS = {
    "bi": DatasetConfig(
        name="bi",
        input_dir=Path("/mnt/data/parameters/ldbc_snb_bi/parameters-sf1"),
        output_dir=Path("ldbc_snb_bi/sf1"),
        file_pattern=r"bi-\d+(?:[ab])?(?:-without-date)?\.csv$",
        header_mode="first-line",
        query_prefix="bi",
    ),
    "ic": DatasetConfig(
        name="ic",
        input_dir=Path("/mnt/data/parameters/ldbc_snb_ic/substitution_parameters-sf1"),
        output_dir=Path("ldbc_snb_ic/sf1"),
        file_pattern=r"interactive_\d+_param\.txt$",
        header_mode="first-line",
        query_prefix="ic",
    ),
    "finbench": DatasetConfig(
        name="finbench",
        input_dir=Path("/mnt/data/parameters/finbench/sf1_read_params"),
        output_dir=Path("finbench/sf1"),
        file_pattern=r"complex_\d+_param\.csv$",
        header_mode="dot-marker",
        query_prefix="complex",
    ),
}


def natural_key(path: Path) -> list[object]:
    return [int(part) if part.isdigit() else part for part in re.split(r"(\d+)", path.name)]


def selected_datasets(name: str) -> list[DatasetConfig]:
    if name == "all":
        return [DATASETS[key] for key in ("bi", "ic", "finbench")]
    return [DATASETS[name]]


def list_parameter_files(config: DatasetConfig) -> list[Path]:
    if not config.input_dir.exists():
        raise FileNotFoundError(f"input directory does not exist: {config.input_dir}")
    pattern = re.compile(config.file_pattern)
    return sorted(
        (path for path in config.input_dir.iterdir() if path.is_file() and pattern.fullmatch(path.name)),
        key=natural_key,
    )


def query_number(config: DatasetConfig, query: str) -> int:
    text = query.strip()
    if config.name == "bi":
        patterns = [
            r"^bi-?(\d+)(?:[ab])?(?:-without-date)?(?:\.csv)?$",
            r"^(\d+)$",
        ]
    elif config.name == "ic":
        patterns = [
            r"^ic-?(\d+)$",
            r"^interactive_(\d+)(?:_param)?(?:\.txt)?$",
            r"^(\d+)$",
        ]
    elif config.name == "finbench":
        patterns = [
            r"^(?:tcr|tsr)-?(\d+)(?:\.cypher)?$",
            r"^complex_(\d+)(?:_param)?(?:\.csv)?$",
            r"^(\d+)$",
        ]
    else:
        patterns = [r"^(\d+)$"]

    for pattern in patterns:
        match = re.fullmatch(pattern, text)
        if match:
            return int(match.group(1))
    raise ValueError(f"cannot parse query for {config.name}: {query}")


def filter_files_for_query(config: DatasetConfig, files: list[Path], query: str | None) -> list[Path]:
    if query is None:
        return files

    number = query_number(config, query)
    if config.name == "bi":
        pattern = re.compile(rf"bi-{number}(?:[ab])?(?:-without-date)?\.csv$")
    elif config.name == "ic":
        pattern = re.compile(rf"interactive_{number}_param\.txt$")
    elif config.name == "finbench":
        pattern = re.compile(rf"complex_{number}_param\.csv$")
    else:
        raise ValueError(f"unsupported workload: {config.name}")

    matches = [path for path in files if pattern.fullmatch(path.name)]
    if not matches:
        raise FileNotFoundError(f"no parameter files for {config.name} query {query} in {config.input_dir}")
    return matches


def query_key_for_file(config: DatasetConfig, path: Path) -> str:
    if config.name == "bi":
        match = re.fullmatch(r"bi-(\d+)(?:[ab])?(-without-date)?\.csv", path.name)
        if match:
            number, without_date = match.groups()
            return f"bi{number}{without_date or ''}"
    if config.name == "ic":
        match = re.fullmatch(r"interactive_(\d+)_param\.txt", path.name)
        if match:
            return f"ic{int(match.group(1))}"
    if config.name == "finbench":
        match = re.fullmatch(r"complex_(\d+)_param\.csv", path.name)
        if match:
            return f"complex{int(match.group(1))}"
    raise ValueError(f"cannot infer query key for {config.name}: {path.name}")


def group_files_by_query(config: DatasetConfig, files: list[Path]) -> dict[str, list[Path]]:
    groups: dict[str, list[Path]] = {}
    for path in files:
        groups.setdefault(query_key_for_file(config, path), []).append(path)
    return {key: sorted(value, key=natural_key) for key, value in sorted(groups.items(), key=lambda item: natural_key(Path(item[0])))}


def read_source_file(path: Path, header_mode: str) -> tuple[list[str], list[str]]:
    lines = path.read_text(encoding="utf-8-sig").splitlines()
    if not lines:
        return [], []
    if header_mode == "first-line":
        return [lines[0]], [line for line in lines[1:] if line.strip()]
    if header_mode == "dot-marker":
        header = []
        rows = []
        for line in lines:
            if not line.strip():
                continue
            if line.strip() == "...":
                header.append(line)
            else:
                rows.append(line)
        return header[:1], rows
    raise ValueError(f"unsupported header mode: {header_mode}")


def sample_rows(rows: list[str], count: int, rng: random.Random, source: Path) -> tuple[list[str], bool]:
    if len(rows) >= count:
        return rng.sample(rows, count), False
    if not rows:
        raise ValueError(f"no parameter rows found in {source}")
    return rng.choices(rows, k=count), True


def write_round_file(path: Path, rounds: list[list[str]], header: str | None = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    content_lines = []
    if header is not None:
        content_lines.append(header)
    for round_index, rows in enumerate(rounds, start=1):
        content_lines.append(f"--round {round_index}--")
        content_lines.extend(rows)
    path.write_text("\n".join(content_lines) + "\n", encoding="utf-8")


def sample_dataset(
    config: DatasetConfig,
    round_count: int,
    param_num: int,
    query: str | None,
    output_root: Path,
    rng: random.Random,
    overwrite: bool,
    include_header: bool,
) -> list[dict[str, object]]:
    source_files = filter_files_for_query(config, list_parameter_files(config), query)
    if not source_files:
        raise FileNotFoundError(f"no parameter files matched {config.file_pattern} in {config.input_dir}")

    output_base = output_root / config.output_dir
    if output_base.exists() and any(output_base.iterdir()) and not overwrite:
        raise FileExistsError(f"output directory is not empty, pass --overwrite to replace files: {output_base}")

    records: list[dict[str, object]] = []
    for query_key, group_sources in group_files_by_query(config, source_files).items():
        all_rows: list[str] = []
        headers: set[str] = set()
        source_row_counts: dict[str, int] = {}
        for source in group_sources:
            header, rows = read_source_file(source, config.header_mode)
            all_rows.extend(rows)
            source_row_counts[str(source)] = len(rows)
            headers.update(header)
        output_header = next(iter(headers)) if include_header and len(headers) == 1 else None
        sampled_rounds = []
        replacement_rounds = 0
        for round_index in range(1, round_count + 1):
            sampled, used_replacement = sample_rows(all_rows, param_num, rng, Path(query_key))
            sampled_rounds.append(sampled)
            replacement_rounds += 1 if used_replacement else 0
        target = output_base / f"{query_key}.txt"
        write_round_file(target, sampled_rounds, output_header)
        records.append(
            {
                "dataset": config.name,
                "query": query_key,
                "sources": [str(source) for source in group_sources],
                "target": str(target),
                "available_rows": len(all_rows),
                "source_row_counts": source_row_counts,
                "sampled_rows_per_round": param_num,
                "rounds": round_count,
                "with_replacement": replacement_rounds > 0,
                "replacement_rounds": replacement_rounds,
                "header_written": output_header is not None,
                "headers": sorted(headers),
            }
        )
    return records


def write_manifest(output_root: Path, records: list[dict[str, object]], args: argparse.Namespace) -> None:
    manifest = {
        "round": args.round_count,
        "param_num": args.param_num,
        "workload": args.workload,
        "query": args.query,
        "seed": args.seed,
        "files": records,
    }
    output_root.mkdir(parents=True, exist_ok=True)
    (output_root / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workload", choices=["all", *DATASETS.keys()], default="all", help="dataset to sample; default samples all datasets")
    parser.add_argument("--query", default=None, help="sample only one query in the selected workload; omitted means all queries")
    parser.add_argument("--round", dest="round_count", type=int, required=True, help="number of sampled parameter groups to generate")
    parser.add_argument("--param-num", dest="param_num", type=int, required=True, help="number of random rows sampled into each output parameter file")
    parser.add_argument("--seed", type=int, default=None, help="optional random seed for reproducible sampling")
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT, help="root directory for sampled parameters")
    parser.add_argument("--overwrite", action="store_true", help="allow writing into existing non-empty output dataset directories")
    parser.add_argument("--include-header", action="store_true", help="write the source header once before the first round marker when all grouped sources share the same header")
    args = parser.parse_args()

    if args.round_count < 1:
        print("--round must be >= 1", file=sys.stderr)
        return 2
    if args.param_num < 1:
        print("--param-num must be >= 1", file=sys.stderr)
        return 2
    if args.query is not None and args.workload == "all":
        print("--query requires --workload bi, ic, or finbench", file=sys.stderr)
        return 2

    rng = random.Random(args.seed)
    records: list[dict[str, object]] = []
    try:
        for config in selected_datasets(args.workload):
            dataset_records = sample_dataset(
                config,
                args.round_count,
                args.param_num,
                args.query,
                args.output_root,
                rng,
                args.overwrite,
                args.include_header,
            )
            records.extend(dataset_records)
            print(
                f"{config.name}: wrote {len(dataset_records)} files under {args.output_root / config.output_dir}",
                flush=True,
            )
        write_manifest(args.output_root, records, args)
    except Exception as exc:
        print(f"ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1

    replacement_count = sum(1 for record in records if record["with_replacement"])
    print(f"done: sampled {len(records)} files, replacement_used={replacement_count}")
    print(f"manifest: {args.output_root / 'manifest.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
