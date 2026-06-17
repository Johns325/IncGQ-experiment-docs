#!/usr/bin/env bash
set -euo pipefail

service postgresql start
runuser -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD 'postgres@';"

export PGHOST=127.0.0.1
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=postgres@

if [ ! -f /root/.m2/repository/com/microsoft/z3/4.8.7/z3-4.8.7.jar ]; then
  echo "[ERROR] Missing /root/.m2/repository/com/microsoft/z3/4.8.7/z3-4.8.7.jar"
  echo "[ERROR] Mount a Maven local repository that already contains com.microsoft:z3:4.8.7."
  exit 2
fi

cd /workspace/pg-view

echo "[1/4] Compile PGVIEW"
mvn compile

echo "[2/4] Check PostgreSQL"
pg_isready -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}"
psql -X -U "${PGUSER}" -c "SELECT version();"

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
