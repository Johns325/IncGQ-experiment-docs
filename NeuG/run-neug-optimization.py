#!/usr/bin/env python3
"""Run NeuG optimized benchmark queries after rebuilding NeuG indexes."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-workload.py"
sys.argv = [str(SCRIPT), "--query-set", "optimization", *sys.argv[1:]]
runpy.run_path(str(SCRIPT), run_name="__main__")
