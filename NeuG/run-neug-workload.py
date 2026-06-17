#!/usr/bin/env python3
"""Convenience entrypoint for NeuG workload runs."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-workload.py"
sys.argv[0] = str(SCRIPT)
runpy.run_path(str(SCRIPT), run_name="__main__")
