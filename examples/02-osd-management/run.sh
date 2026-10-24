#!/usr/bin/env bash
# 02-osd-management/run.sh
set -euo pipefail
OSD_ID="${OSD_ID:-0}"
echo "[1/4] OSD tree..."; ceph osd tree
echo "[2/4] Mark out..."; ceph osd out "osd.${OSD_ID}"
for i in $(seq 1 6); do ceph -s | grep -E "pgs:|health:" || true; sleep 5; done
echo "[3/4] Remove..."; ceph osd crush remove "osd.${OSD_ID}"; ceph auth del "osd.${OSD_ID}"; ceph osd rm "osd.${OSD_ID}"
echo "Done."
