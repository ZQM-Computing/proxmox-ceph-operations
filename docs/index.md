# Proxmox VE & Ceph Operations

Field-tested Proxmox VE and Ceph operations material: cluster health-check routines and scripts, backup and restore discipline, cloud-init VM templates, OSD replacement procedure, and upgrade checklists — the runbooks that keep a hyperconverged cluster boring, written from operating one in production for large geospatial workloads.

No theory-first filler: every procedure states its order of operations, the checks that gate each step, and the failure it exists to prevent.

## Design notes

[Design notes](design-notes.md) — failure domains, pool layout by workload (including the raster-vs-database tiering call for geospatial data), cluster networking, and capacity posture for 3–8 node clusters. This page lives in `docs/` alongside this index.

## Runbooks

The runbooks live in `runbooks/` at the repository root:

| Runbook | Covers |
|---|---|
| [Cluster health](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/runbooks/cluster-health.md) | Daily/weekly/monthly checks, quorum, PG states, red-state first moves |
| [Backup discipline](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/runbooks/backups.md) | PBS + archive tiers, verification, freshness monitoring, restore drills — and why Ceph replication is not a backup |
| [OSD replacement](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/runbooks/osd-replacement.md) | Graceful drain vs. dead-disk path, backfill throttling, Proxmox `pveceph` notes |
| [VM templates](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/runbooks/vm-templates.md) | Cloud-init template builds, clone-and-personalize, template hygiene |
| [Upgrade checklist](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/runbooks/upgrade-checklist.md) | Sequenced Proxmox + Ceph upgrades with health gates and the `noout` discipline |

## Scripts

All read-only; they report, they never mutate. See [`scripts/`](https://github.com/ZQM-Computing/proxmox-ceph-operations/tree/main/scripts): `ceph_health_check.sh`, `pve_node_report.sh`, `backup_freshness.sh`, plus `check_docs.py`.

## Examples and patterns

- [Examples](https://github.com/ZQM-Computing/proxmox-ceph-operations/tree/main/examples): `01-pool-creation`, `02-osd-management`, `03-crush-rules`, `04-monitoring`, `05-backup-restore`, `06-performance-tuning`.
- [Patterns](https://github.com/ZQM-Computing/proxmox-ceph-operations/tree/main/patterns): Ceph SQL patterns (`07_pool_tiering.sql`, `08_backup_restore_drill.sql`). This is real Ceph pool-pattern content for this repository's own subject — not a leftover of the cookbook rebrand, and it is intentionally not renamed.
- [Tests](https://github.com/ZQM-Computing/proxmox-ceph-operations/tree/main/tests): smoke tests (`test_basic.py`).

## Design principles

1. **Read-only by default.** Every script here only observes. Procedures that mutate are written as runbooks with explicit gates, not hidden inside automation.
2. **Order is the safety mechanism.** Upgrade and OSD procedures specify the sequence and the health checks between steps; the steps themselves are easy.
3. **Restore is the product.** Backup guidance is organized around verification and timed restore drills, not capture settings.
4. **Small-cluster honest.** Advice is scoped to 3–8 nodes and says where it stops applying, instead of pretending enterprise patterns shrink for free.

## Contributing and license

Corrections from your own cluster scars are the most valuable contributions — especially version-specific behavior. See [CONTRIBUTING.md](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/CONTRIBUTING.md). Scripts must stay read-only and pass shellcheck. MIT — see [LICENSE](https://github.com/ZQM-Computing/proxmox-ceph-operations/blob/main/LICENSE).
