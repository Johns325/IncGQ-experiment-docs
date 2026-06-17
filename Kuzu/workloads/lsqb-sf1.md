# Kuzu LSQB SF1 workload

Database:

```text
/mnt/data/imported_data/kuzu/lsqb/sf1
```

Benchmark query directories:

```text
baseline:     Kuzu/queries/baseline/lsqb
optimized:    Kuzu/queries/optimized/lsqb
materialized: Kuzu/queries/index/lsqb
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/run-kuzu-baseline.py --workload lsqb-sf1 --query q1 --mode execute --fetch-rows 5
Kuzu/run-kuzu-optimization.py --workload lsqb-sf1 --query q1 --mode execute --fetch-rows 5
```

Legacy smoke wrapper:

```bash
Kuzu/scripts/run-lsqb-sf1.sh --query q1 --mode execute --fetch-rows 5
```

`schema.cypher` is skipped by default in the legacy runner because it is not a workload query.

Optimized LSQB coverage currently includes `q1`, `q2`, `q3`, `q4`, and `q7`.
