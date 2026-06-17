#!/usr/bin/env python3
"""Convenience entrypoint for Neo4j workload runs.

The implementation lives in scripts/run-workload.py so the per-workload shell
wrappers and this top-level script share the same behavior.
"""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-workload.py"
sys.argv[0] = str(SCRIPT)
runpy.run_path(str(SCRIPT), run_name="__main__")
