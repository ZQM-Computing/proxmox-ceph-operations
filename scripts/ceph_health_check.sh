#!/usr/bin/env bash
# ceph_health_check.sh -- read-only Ceph health summary for cron or manual runs.
#
# Prints cluster status, OSD utilization, and placement-group state, then
# exits 0 only when the cluster reports HEALTH_OK. Any other state exits 1
# with the health detail on stdout, so a cron wrapper or monitoring check
# can alert on it. This script never modifies the cluster.
#
# Usage: ./ceph_health_check.sh [--json]
#   --json   Emit a single JSON object instead of text (for piping to jq
#            or a monitoring system).

set -euo pipefail

command -v ceph >/dev/null 2>&1 || {
    echo "ERROR: 'ceph' CLI not found in PATH. Run this on a monitor/admin node." >&2
    exit 2
}

health="$(ceph health 2>/dev/null || echo 'UNREACHABLE')"
status_line="$(ceph status --format plain 2>/dev/null | head -n 1 || true)"
osd_summary="$(ceph osd df --format plain 2>/dev/null | tail -n +2 | head -n 20 || true)"
pg_summary="$(ceph pg stat 2>/dev/null || true)"

if [[ "${1:-}" == "--json" ]]; then
    # Minimal JSON without jq: health strings are simple tokens in practice,
    # but escape quotes defensively.
    esc() { printf '%s' "$1" | sed 's/"/\\"/g'; }
    printf '{"health":"%s","status":"%s","pgs":"%s"}\n' \
        "$(esc "${health}")" "$(esc "${status_line}")" "$(esc "${pg_summary}")"
else
    echo "== Ceph health =="
    echo "${health}"
    if [[ "${health}" != "HEALTH_OK" ]]; then
        echo
        echo "== Health detail =="
        ceph health detail || true
    fi
    echo
    echo "== Cluster status (first line) =="
    echo "${status_line}"
    echo
    echo "== OSD utilization (top 20 lines) =="
    echo "${osd_summary}"
    echo
    echo "== Placement groups =="
    echo "${pg_summary}"
fi

[[ "${health}" == "HEALTH_OK" ]]
