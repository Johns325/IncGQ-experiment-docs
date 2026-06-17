#!/usr/bin/env python3
"""Import NeuG workload datasets with local import configs and NeuG bulk_loader."""

from __future__ import annotations

import argparse
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


LOCAL_NEUG_ROOT = Path("/root/workspace/neug")
NEUG_DOC_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BULK_LOADER = LOCAL_NEUG_ROOT / "build" / "tools" / "utils" / "bulk_loader"
CONFIG_ROOT = NEUG_DOC_ROOT / "import" / "configs"
TMP_CONFIG_DIR = Path("/tmp/neug-local-import-configs")


@dataclass(frozen=True)
class WorkloadImport:
    name: str
    graph_config: Path
    import_config: Path
    data_dir: Path
    db_dir: Path


WORKLOADS = {
    "ic-sf1": WorkloadImport(
        name="ic-sf1",
        graph_config=CONFIG_ROOT / "ldbc" / "graph.yaml",
        import_config=CONFIG_ROOT / "ldbc" / "import.yaml",
        data_dir=Path("/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter"),
        db_dir=Path("/mnt/data/imported_data/incgq/ic-sf1"),
    ),
    "bi-sf1": WorkloadImport(
        name="bi-sf1",
        graph_config=CONFIG_ROOT / "ldbc" / "graph-bi.yaml",
        import_config=CONFIG_ROOT / "ldbc" / "import-bi-sf1.yaml",
        data_dir=Path(
            "/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk/graphs/csv/bi/"
            "composite-projected-fk/initial_snapshot"
        ),
        db_dir=Path("/mnt/data/imported_data/incgq/bi-sf1"),
    ),
    "finbench-sf1": WorkloadImport(
        name="finbench-sf1",
        graph_config=CONFIG_ROOT / "finbench" / "graph-finbench.yaml",
        import_config=CONFIG_ROOT / "finbench" / "import-finbench-sf1.yaml",
        data_dir=Path("/mnt/data/datasets/finbench/sf1/snapshot"),
        db_dir=Path("/mnt/data/imported_data/incgq/finbench-sf1"),
    ),
    "lsqb-sf1": WorkloadImport(
        name="lsqb-sf1",
        graph_config=CONFIG_ROOT / "lsqb" / "graph-lsqb.yaml",
        import_config=CONFIG_ROOT / "lsqb" / "import-lsqb.yaml",
        data_dir=Path("/mnt/data/datasets/lsqb/social-network-sf1-projected-fk"),
        db_dir=Path("/mnt/data/imported_data/incgq/lsqb-sf1"),
    ),
}


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def write_yaml(path: Path, doc: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        yaml.safe_dump(doc, handle, sort_keys=False)


def prepare_import_config(workload: WorkloadImport) -> Path:
    doc = load_yaml(workload.import_config)
    doc.setdefault("loading_config", {}).setdefault("data_source", {})["location"] = str(workload.data_dir)
    out = TMP_CONFIG_DIR / f"import-{workload.name}.yaml"
    write_yaml(out, doc)
    return out


def mapping_inputs(import_doc: dict[str, Any], data_dir: Path) -> list[Path]:
    paths: list[Path] = []
    for section in ("vertex_mappings", "edge_mappings"):
        for mapping in import_doc.get(section, []) or []:
            for item in mapping.get("inputs", []) or []:
                paths.append(data_dir / item)
    return paths


def preflight(workload: WorkloadImport, import_config: Path, bulk_loader: Path) -> None:
    required = [bulk_loader, workload.graph_config, workload.import_config, workload.data_dir]
    missing_required = [path for path in required if not path.exists()]
    if missing_required:
        raise FileNotFoundError("missing required paths:\n" + "\n".join(str(path) for path in missing_required))
    import_doc = load_yaml(import_config)
    missing_inputs = [path for path in mapping_inputs(import_doc, workload.data_dir) if not path.exists()]
    if missing_inputs:
        preview = "\n".join(str(path) for path in missing_inputs[:20])
        raise FileNotFoundError(f"{workload.name} has {len(missing_inputs)} missing input files:\n{preview}")


def ensure_target(db_dir: Path, overwrite: bool) -> None:
    if db_dir.exists() and any(db_dir.iterdir()):
        if not overwrite:
            raise FileExistsError(f"{db_dir} exists and is not empty; pass --overwrite to replace it")
        shutil.rmtree(db_dir)
    db_dir.mkdir(parents=True, exist_ok=True)


def import_one(
    workload: WorkloadImport,
    overwrite: bool,
    parallelism: int,
    build_csr_in_mem: bool,
    use_mmap_vector: bool,
    bulk_loader: Path,
) -> None:
    import_config = prepare_import_config(workload)
    preflight(workload, import_config, bulk_loader)
    ensure_target(workload.db_dir, overwrite)

    cmd = [
        str(bulk_loader),
        "-g",
        str(workload.graph_config),
        "-l",
        str(import_config),
        "-d",
        str(workload.db_dir),
        "-p",
        str(parallelism),
    ]
    if build_csr_in_mem:
        cmd.append("--build-csr-in-mem")
    if use_mmap_vector:
        cmd.append("--use-mmap-vector")

    print(" ".join(cmd), flush=True)
    subprocess.run(cmd, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workload", choices=sorted(WORKLOADS), action="append")
    parser.add_argument("--all", action="store_true", help="import all supported SF1 workloads")
    parser.add_argument("--overwrite", action="store_true", help="replace an existing non-empty target database directory")
    parser.add_argument("--bulk-loader", type=Path, default=DEFAULT_BULK_LOADER, help="path to NeuG bulk_loader binary")
    parser.add_argument("-p", "--parallelism", type=int, default=4)
    parser.add_argument("--build-csr-in-mem", action="store_true", default=True)
    parser.add_argument("--no-build-csr-in-mem", dest="build_csr_in_mem", action="store_false")
    parser.add_argument("--use-mmap-vector", action="store_true")
    args = parser.parse_args()

    if args.all:
        names = list(WORKLOADS)
    elif args.workload:
        names = args.workload
    else:
        parser.error("pass --all or at least one --workload")

    for name in names:
        workload = WORKLOADS[name]
        print(f"=== importing {name} into {workload.db_dir} with {args.bulk_loader} ===", flush=True)
        import_one(
            workload,
            overwrite=args.overwrite,
            parallelism=args.parallelism,
            build_csr_in_mem=args.build_csr_in_mem,
            use_mmap_vector=args.use_mmap_vector,
            bulk_loader=args.bulk_loader,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
