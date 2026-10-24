#!/usr/bin/env bash
# 01-pool-creation/run.sh
set -euo pipefail
POOL_NAME="${POOL_NAME:-rbd-pool}"; PG_NUM="${PG_NUM:-128}"; REPLICATION="${REPLICATION:-3}"
echo "[1/4] Verifying Ceph cluster health..."; ceph health
echo "[2/4] Creating replicated pool '${POOL_NAME}'..."; pveceph pool create "${POOL_NAME}" --add_storages 0 --pg_num "${PG_NUM}" --size "${REPLICATION}" --min_size 2 --application rbd
echo "[3/4] Enabling RBD..."; ceph osd pool application enable "${POOL_NAME}" rbd --force; rbd pool init "${POOL_NAME}"
echo "[4/4] Verifying..."; ceph osd pool ls detail | grep -A2 "${POOL_NAME}"
echo "Done."
