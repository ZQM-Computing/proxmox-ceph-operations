# proxmox-ceph-operations — Proxmox VE & Ceph Operations Runbooks and Scripts

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a> •
  <a href="https://github.com/ZQM-Labs">ZQM Labs</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

[![Validate scripts](https://github.com/ZQM-Computing/proxmox-ceph-operations/actions/workflows/validate.yml/badge.svg)](https://github.com/ZQM-Computing/proxmox-ceph-operations/actions/workflows/validate.yml)

Field-tested **Proxmox VE** and **Ceph** operations material: cluster **health-check** routines and scripts, **backup and restore discipline**, **cloud-init VM templates**, **OSD replacement** procedure, and **upgrade checklists** — the runbooks that keep a hyperconverged cluster boring, written from operating one in production for large geospatial workloads.

No theory-first filler: every procedure states its order of operations, the checks that gate each step, and the failure it exists to prevent.

## Repository role and status

**Status:** Active, public.

**What this repository is:** Proxmox VE + Ceph operations material — cluster health-check routines, backup and restore discipline, cloud-init VM templates, OSD replacement procedure, and upgrade checklists, written from operating a hyperconverged cluster in production.

**What it contributes:** Part of the ZQM Computing public geospatial portfolio — production-grade pattern and reference repositories that document geospatial engineering practice across the stack. This repository is the reusable pattern library for its layer: working code and runbooks that practitioners can lift into their own pipelines, and portfolio evidence of the engineering practice behind ZQM Computing. The umbrella index for the series is [geospatial-patterns](https://github.com/ZQM-Computing/geospatial-patterns).

**Standing:** The portfolio program was completed and Tier-1 hardened on 2026-10-15, with prose CI enforced as required status checks. This repository is standalone — no other repository or deployment depends on it.

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

## Usage

Use the runbooks in [`runbooks/`](runbooks/) for day-to-day Proxmox VE and
Ceph operations — start with the cluster health runbook for routine
checks, and follow the design principles above before applying any
procedure to a live cluster.

## Contributing

Corrections from your own cluster scars are the most valuable contributions here — especially version-specific behavior. See [`CONTRIBUTING.md`](CONTRIBUTING.md). Scripts must stay read-only and pass shellcheck.

## Maintainer

Maintained by [ZQM Computing](https://github.com/ZQM-Computing). Distilled from production Proxmox VE / Ceph operations — including running the platform behind a multi-terabyte spatial data practice — by Alex Zelenski, GISP.

## Related repositories

- [postgis-patterns](https://github.com/ZQM-Computing/postgis-patterns) — Production PostGIS patterns: spatial indexing, joins & KNN, SRID management, vector tiles, data quality, partitioning
- [duckdb-spatial-patterns](https://github.com/ZQM-Computing/duckdb-spatial-patterns) — DuckDB Spatial patterns for analytical geospatial SQL: GeoParquet, spatial joins, KNN, H3 aggregation — no server required
- [pgrouting-patterns](https://github.com/ZQM-Computing/pgrouting-patterns) — pgRouting network analysis on PostGIS: shortest path, driving distance, isochrones, turn restrictions, traffic-aware routing
- [geopandas-patterns](https://github.com/ZQM-Computing/geopandas-patterns) — GeoPandas/Shapely patterns for Python geospatial workflows: spatial joins, CRS handling, overlays, interpolation, performance
- [gdal-patterns](https://github.com/ZQM-Computing/gdal-patterns) — GDAL/OGR command-line patterns: conversion, reprojection, clipping, mosaicking — production-tested, runnable examples
- [stac-patterns](https://github.com/ZQM-Computing/stac-patterns) — STAC patterns for geospatial data discovery: catalogs, item validation, search API, bulk operations, cloud deployment
- [maplibre-patterns](https://github.com/ZQM-Computing/maplibre-patterns) — MapLibre GL JS patterns for frontend vector tile rendering: custom layers, 3D terrain, performance tuning, interactive maps
- [cog-patterns](https://github.com/ZQM-Computing/cog-patterns) — Cloud Optimized GeoTIFF patterns: creation, validation, TiTiler serving, xarray integration, performance benchmarking
- [geoparquet-patterns](https://github.com/ZQM-Computing/geoparquet-patterns) — GeoParquet patterns for columnar geospatial analytics: partitioning, predicate pushdown, DuckDB/Spark integration
- [h3-patterns](https://github.com/ZQM-Computing/h3-patterns) — H3 hexagonal grid patterns: indexing, aggregation, visualization, grid comparisons, performance benchmarks
- [qgis-resources](https://github.com/ZQM-Computing/qgis-resources) — QGIS expressions, PyQGIS snippets, Processing scripts, styles, and QField field-collection guides
- [geospatial-api-reference](https://github.com/ZQM-Computing/geospatial-api-reference) — OGC API – Features reference implementation with FastAPI and PostGIS backends
- [ollama-fleet-patterns](https://github.com/ZQM-Computing/ollama-fleet-patterns) — Ollama fleet operations: model management, health checks, load-spreading, VRAM budgeting, dependency-light RAG
- [geospatial-patterns](https://github.com/ZQM-Computing/geospatial-patterns) — Umbrella index for all ZQM geospatial pattern repos

## Installation

No installation — clone the repository; scripts run directly with bash.

## License

MIT — see [`LICENSE`](LICENSE).

*Part of [ZQM Computing](https://github.com/ZQM-Computing) — geospatial engineering, scientific computing, and infrastructure patterns; the geospatial arm of [ZQM Labs](https://zqmlabs.com), makers of Z's Quests & Mischief location games.*

<!-- ZQM-FOOTER-START -->
<!-- markdownlint-disable MD033 -->
---

<p align="center">
  <em>Play more. Plan less.</em><br>
  <a href="https://zqmlabs.com">zqmlabs.com</a> •
  <a href="https://github.com/ZQM-Labs">ZQM Labs</a> •
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-FOOTER-END -->
