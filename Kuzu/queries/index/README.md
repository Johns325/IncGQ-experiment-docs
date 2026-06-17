# Kuzu materializations for Neug index templates

The files in this directory are Kuzu translations of Neug's index/setup templates under `/root/workspace/neug/examples/cpp/query_templates`.

These are not native Kuzu `CREATE INDEX` statements. Neug's templates materialize derived values into node tables, relationship tables, or auxiliary relationship tables. The Kuzu scripts here do the same with Kuzu-supported DDL/DML:

- node/relationship properties: `ALTER TABLE ... ADD ...` followed by `MATCH ... SET ...`
- auxiliary relationship tables: `DROP TABLE IF EXISTS`, `CREATE REL TABLE`, then `MATCH ... CREATE`

Kuzu 0.11.3 supports `ALTER TABLE ... DROP IF EXISTS <property>`, but ordinary property `ADD IF NOT EXISTS` is not consistently available. These scripts are repeatable by dropping the materialized property/table first and then recreating it.

For safety, validate these scripts on a copied database before running them against the canonical imported databases.
