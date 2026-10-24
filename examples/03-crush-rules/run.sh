#!/usr/bin/env bash
# 03-crush-rules/run.sh
set -euo pipefail
RULE_NAME="${RULE_NAME:-ssd-replicated}"; POOL_NAME="${POOL_NAME:-fast-pool}"
echo "[1/3] Create rule..."; ceph osd crush rule create-replicated "${RULE_NAME}" default host ssd
echo "[2/3] Create pool..."; pveceph pool create "${POOL_NAME}" --pg_num 64 --size 3 --min_size 2 --crush_rule "${RULE_NAME}" --application rbd
echo "[3/3] Verify..."; ceph osd pool get "${POOL_NAME}" crush_rule; ceph osd crush rule dump "${RULE_NAME}"
echo "Done."
