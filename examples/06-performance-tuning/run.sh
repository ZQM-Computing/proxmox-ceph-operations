#!/usr/bin/env bash
# 06-performance-tuning/run.sh
set -euo pipefail
ceph config set osd osd_recovery_max_active 3
ceph config set osd osd_max_backfills 2
ceph config set osd bluestore_cache_autotune 1
ceph config set client rbd_cache 1
ceph osd pool set rbd pg_autoscale_mode on
ceph osd pool autoscale-status
ceph config dump | grep -E "recovery|bluestore_cache|rbd_cache" || true
echo "Done."
