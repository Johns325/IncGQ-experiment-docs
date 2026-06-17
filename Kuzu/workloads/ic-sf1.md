# Kuzu IC SF1 workload

Database:

```text
/mnt/data/imported_data/kuzu/ic-sf1
```

Benchmark query directories:

```text
baseline:     Kuzu/queries/baseline/ldbc-ic
optimized:    Kuzu/queries/optimized/ldbc-ic
materialized: Kuzu/queries/index/ldbc-ic
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/run-kuzu-baseline.py --workload ic-sf1 --query ic1 --mode execute --param-count 1
Kuzu/run-kuzu-optimization.py --workload ic-sf1 --query ic1 --mode execute --param-count 1
```

Legacy smoke wrapper:

```bash
Kuzu/scripts/run-ic-sf1.sh --query ic1 --mode execute --param-count 1
```

IC query files use imported Kuzu labels and relationships such as `PERSON`, `PLACE`, `ORGANISATION`, `KNOWS`, `ISLOCATEDIN`, `STUDYAT`, `WORKAT`, `HASCREATOR`, and `REPLYOF`.

Runner note: maintained Kuzu benchmark runners force `num_threads=1` for every workload. Older notes or timings that mention `threads=16` are historical and should not be used for current benchmark runs.
