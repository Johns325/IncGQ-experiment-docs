# Kuzu LDBC IC baseline queries

These queries target `/mnt/data/imported_data/kuzu/ic-sf1` through the current Kuzu schema.

They are run by:

```bash
Kuzu/run-kuzu-baseline.py --workload ic-sf1 --query ic1 --mode execute
```

The legacy wrapper also resolves this directory:

```bash
Kuzu/scripts/run-ic-sf1.sh --query ic1 --mode execute
```

Schema conventions used by these files:

- Person nodes use `PERSON`.
- Places use `PLACE` plus `type` filters where city/country semantics matter.
- Organisations use `ORGANISATION` plus `type` filters where company/university semantics matter.
- Relationships use imported uppercase names such as `KNOWS`, `ISLOCATEDIN`, `STUDYAT`, `WORKAT`, `HASCREATOR`, and `REPLYOF`.
- Neo4j shortest-path forms were replaced by Kuzu-supported variable-length path rewrites where needed.
