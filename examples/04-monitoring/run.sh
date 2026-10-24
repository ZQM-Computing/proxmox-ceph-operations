#!/usr/bin/env bash
# 04-monitoring/run.sh
set -euo pipefail
echo "[1/5] Status..."; ceph -s
echo "[2/5] Health..."; ceph health detail
echo "[3/5] OSD df..."; ceph osd df
echo "[4/5] PG stat..."; ceph pg stat
echo "[5/5] Capacity..."; ceph df
echo "Done."
