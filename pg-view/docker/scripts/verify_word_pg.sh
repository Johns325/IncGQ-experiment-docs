#!/usr/bin/env bash
set -euo pipefail

cd /workspace/pg-view

echo "[1/4] Compile PGVIEW"
mvn compile

echo "[2/4] Check PostgreSQL"
pg_isready -h "${PGHOST:-postgres}" -p "${PGPORT:-5432}" -U "${PGUSER:-postgres}"
psql -X -U "${PGUSER:-postgres}" -c "SELECT version();"

echo "[3/4] Generate WORD CSV"
cd /workspace/pg-view/experiment
if [ -f "${NLTK_DATA:-/usr/local/share/nltk_data}/corpora/wordnet.zip" ]; then
  echo "[INFO] Found existing WordNet data."
else
  timeout 180 python3 -m nltk.downloader -d "${NLTK_DATA:-/usr/local/share/nltk_data}" wordnet
fi
python3 ./prep_dataset_sources.py word

echo "[4/4] Create PostgreSQL snapshot"
./prep_db_snapshots.sh -p pg -d word

ls -lh /workspace/pg-view/experiment/dataset/snapshots/postgres/word.sql
