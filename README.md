# proxmox-ceph-operations — Proxmox VE & Ceph Operations Runbooks and Scripts

Field-tested **Proxmox VE** and **Ceph** operations material: cluster **health-check** routines and scripts, **backup and restore discipline**, **cloud-init VM templates**, **OSD replacement** procedure, and **upgrade checklists** — the runbooks that keep a hyperconverged cluster boring, written from operating one in production for large geospatial workloads.

No theory-first filler: every procedure states its order of operations, the checks that gate each step, and the failure it exists to prevent.

## What's inside

**Runbooks** ([`runbooks/`](runbooks/))

| Runbook | Covers |
|---|---|
| [Cluster health](runbooks/cluster-health.md) | Daily/weekly/monthly checks, quorum, PG states, red-state first moves |
| [Backup discipline](runbooks/backups.md) | PBS + archive tiers, verification, freshness monitoring, restore drills — and why Ceph replication is not a backup |
| [OSD replacement](runbooks/osd-replacement.md) | Graceful drain vs. dead-disk path, backfill throttling, Proxmox `pveceph` notes |
| [VM templates](runbooks/vm-templates.md) | Cloud-init template builds, clone-and-personalize, template hygiene |
| [Upgrade checklist](runbooks/upgrade-checklist.md) | Sequenced Proxmox + Ceph upgrades with health gates and the `noout` discipline |

**Scripts** ([`scripts/`](scripts/)) — all read-only; they report, they never mutate:

| Script | What it does |
|---|---|
| `ceph_health_check.sh` | Health summary + detail; exits nonzero unless `HEALTH_OK` (cron/monitoring friendly, `--json` mode) |
| `pve_node_report.sh` | One-shot snapshot: quorum, nodes, guests, storage, load |
| `backup_freshness.sh` | Newest vzdump archive per guest, flags anything older than your limit |

**Design notes** ([`docs/design-notes.md`](docs/design-notes.md)) — failure domains, pool layout by workload (including the raster-vs-database tiering call for geospatial data), cluster networking, and capacity posture for 3–8 node clusters.

## Who this is for

Homelabbers graduating to a second node and wondering what "operating Ceph" actually involves day to day; small-shop and consultancy admins running Proxmox in production without a dedicated infrastructure team; and anyone evaluating hyperconverged storage who wants the operational truth — quorum is a network property, replication is not backup, and nearfull is a planning failure — before the purchase order, not after the first outage.

## Design principles

1. **Read-only by default.** Every script here only observes. Procedures that mutate are written as runbooks with explicit gates, not hidden inside automation.
2. **Order is the safety mechanism.** Upgrade and OSD procedures specify the sequence and the health checks between steps; the steps themselves are easy.
3. **Restore is the product.** Backup guidance is organized around verification and timed restore drills, not capture settings.
4. **Small-cluster honest.** Advice is scoped to 3–8 nodes and says where it stops applying, instead of pretending enterprise patterns shrink for free.

## Repository layout

```text
.
├── runbooks/   # health, backups, OSD replacement, templates, upgrades
├── scripts/    # read-only health/report/freshness scripts (bash)
├── docs/       # design notes for small hyperconverged clusters
└── .github/    # CI: shellcheck + bash syntax on the scripts
```

## Contributing

Corrections from your own cluster scars are the most valuable contributions here — especially version-specific behavior. See [`CONTRIBUTING.md`](CONTRIBUTING.md). Scripts must stay read-only and pass shellcheck.

## Maintainer

Maintained by [ZQM Computing](https://github.com/ZQM-Computing). Distilled from production Proxmox VE / Ceph operations — including running the platform behind a multi-terabyte spatial data practice — by Alex Zelenski, GISP.

## License

MIT — see [`LICENSE`](LICENSE).
