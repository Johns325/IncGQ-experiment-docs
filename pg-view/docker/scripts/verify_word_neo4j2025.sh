#!/usr/bin/env bash
set -euo pipefail

PGVIEW_HOME="${PGVIEW_HOME:-/workspace/pg-view}"
DATASET="${PGVIEW_DATASET:-word}"
SOURCE_NEO4J_HOME="${NEO4J_HOME:-/opt/neo4j}"
WORK_NEO4J_HOME="${WORK_NEO4J_HOME:-/tmp/neo4j-work}"
NEO4J_DATABASE="${NEO4J_DATABASE:-neo4j}"
JAVA21_HOME="${JAVA21_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"
NLTK_DATA="${NLTK_DATA:-/usr/local/share/nltk_data}"

if [ ! -x "${SOURCE_NEO4J_HOME}/bin/neo4j-admin" ]; then
  echo "[ERROR] Missing ${SOURCE_NEO4J_HOME}/bin/neo4j-admin"
  echo "[ERROR] Mount a Neo4j 2025 standalone directory at ${SOURCE_NEO4J_HOME}."
  exit 2
fi

if [ ! -x "${JAVA21_HOME}/bin/java" ]; then
  echo "[ERROR] Missing Java 21 at ${JAVA21_HOME}"
  exit 2
fi

cd "${PGVIEW_HOME}"

echo "[1/5] Compile PGVIEW"
mvn compile

echo "[2/5] Ensure ${DATASET} Neo4j CSV exists"
cd "${PGVIEW_HOME}/experiment"
TARGET_NODE="dataset/targets/${DATASET}/neo4j/node/node.csv"
TARGET_EDGE="dataset/targets/${DATASET}/neo4j/edge/edge.csv"

if [ ! -f "${TARGET_NODE}" ] || [ ! -f "${TARGET_EDGE}" ]; then
  if [ "${DATASET}" = "word" ]; then
    if [ -f "${NLTK_DATA}/corpora/wordnet.zip" ]; then
      echo "[INFO] Found existing WordNet data."
    else
      timeout 180 python3 -m nltk.downloader -d "${NLTK_DATA}" wordnet
    fi
  fi
  python3 ./prep_dataset_sources.py "${DATASET}"
fi

if [ ! -f "${TARGET_NODE}" ] || [ ! -f "${TARGET_EDGE}" ]; then
  echo "[ERROR] Missing Neo4j CSV files for dataset ${DATASET}."
  exit 2
fi

echo "[3/5] Prepare temporary Neo4j home"
rm -rf "${WORK_NEO4J_HOME}"
cp -a "${SOURCE_NEO4J_HOME}" "${WORK_NEO4J_HOME}"

export JAVA_HOME="${JAVA21_HOME}"
export PATH="${JAVA_HOME}/bin:${PATH}"

"${WORK_NEO4J_HOME}/bin/neo4j-admin" --version

echo "[4/5] Import ${DATASET} CSV into Neo4j ${NEO4J_DATABASE}"
rm -rf "${WORK_NEO4J_HOME}/data/databases/${NEO4J_DATABASE}"
rm -rf "${WORK_NEO4J_HOME}/data/transactions/${NEO4J_DATABASE}"
mkdir -p "${WORK_NEO4J_HOME}/data/databases"
mkdir -p "${WORK_NEO4J_HOME}/data/transactions"

"${WORK_NEO4J_HOME}/bin/neo4j-admin" database import full \
  --overwrite-destination=true \
  --id-type=integer \
  --delimiter="," \
  --skip-bad-relationships=true \
  --nodes="${PGVIEW_HOME}/experiment/${TARGET_NODE}" \
  --relationships="${PGVIEW_HOME}/experiment/${TARGET_EDGE}" \
  -- \
  "${NEO4J_DATABASE}"

echo "[5/5] Dump Neo4j database"
SNAPSHOT_DIR="${PGVIEW_HOME}/experiment/dataset/snapshots/neo4j2025/${DATASET}"
rm -rf "${SNAPSHOT_DIR}"
mkdir -p "${SNAPSHOT_DIR}"

"${WORK_NEO4J_HOME}/bin/neo4j-admin" database dump \
  --overwrite-destination=true \
  --to-path="${SNAPSHOT_DIR}" \
  "${NEO4J_DATABASE}"

ls -lh "${SNAPSHOT_DIR}/${NEO4J_DATABASE}.dump"
