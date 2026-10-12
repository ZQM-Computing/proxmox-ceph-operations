#!/usr/bin/env bash
# pve_node_report.sh -- read-only Proxmox VE node/cluster snapshot.
#
# One command that answers "what is this cluster doing right now":
# quorum state, node list, guest inventory, and storage usage. Safe to
# run any time; it changes nothing. Run it on any cluster node.
#
# Usage: ./pve_node_report.sh

set -euo pipefail

for cmd in pvecm qm pct pvesm; do
    command -v "${cmd}" >/dev/null 2>&1 || {
        echo "ERROR: '${cmd}' not found. Run this on a Proxmox VE node." >&2
        exit 2
    }
done

echo "== Cluster quorum =="
pvecm status | sed -n '1,12p'

echo
echo "== Nodes =="
pvecm nodes || true

echo
echo "== Virtual machines =="
qm list

echo
echo "== Containers =="
pct list

echo
echo "== Storage =="
pvesm status

echo
echo "== Node load / memory =="
uptime
free -h
