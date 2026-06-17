#!/usr/bin/env python3
"""Run Kuzu optimized benchmark queries after materializing Neug index results."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-benchmark.py"
sys.argv = [str(SCRIPT), "--query-set", "optimization", *sys.argv[1:]]
runpy.run_path(str(SCRIPT), run_name="__main__")
