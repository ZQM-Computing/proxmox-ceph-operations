# Design notes: small-cluster Proxmox + Ceph that survives contact with reality

Hard-won layout guidance for hyperconverged clusters in the 3–8 node range — the scale where Ceph is both the best answer and entirely unforgiving of casual design.

## Failure domains are the design

- **Replicate across hosts, never within one.** CRUSH rules must place replicas on different hosts (`failure-domain=host`). A 3× pool on a single host is a RAID array with extra latency and none of the honesty.
- **Three nodes is a minimum, not a comfort zone.** With 3 hosts and size 3 / min_size 2, losing one host leaves you running on the edge of your own redundancy until it returns. Four to five hosts is where a small cluster starts forgiving mistakes. Plan purchases for the odd numbers quorum likes.
- **Quorum is a network property.** Corosync and Ceph monitors both die by bad networking before they die by bad software: dedicated cluster network (or at least a dedicated VLAN with honest MTU), no Wi-Fi, no clever bonding modes you haven't failure-tested by pulling cables.

## Pools by workload, not by org chart

| Pool | Profile | Notes |
| --- | --- | --- |
| VM disks (rbd) | Replicated 3×, SSD/NVMe if guests are latency-sensitive | The default pool; keep it boring |
| Bulk / archive | Erasure-coded (e.g., k=4, m=2) once the cluster has 6+ hosts | EC is for capacity tiers; on 3 hosts it is a trap |
| CephFS for shared files | Replicated, one active MDS + standby | Lovely for shared datasets; respect the client cache/attr behavior under many small files |
| Backup target | **Not on this cluster's Ceph** | A backup stored on the system it protects is a copy, not a backup — see [backups.md](../runbooks/backups.md) |

For geospatial workloads specifically: raster pyramids and tile caches are *throughput* data (large sequential reads) while spatial databases are *latency* data (small random reads/writes). If the budget forces one fast tier, the database and VM system disks get it; bulk raster lives happily on the capacity tier — and regenerable tile caches can even sit outside the redundancy story, clearly labeled as disposable.

## Networks

- **Public network** (clients/guests) and **cluster network** (OSD replication/heartbeat) separated once node count or disk count makes replication traffic visible to guests. On NVMe clusters, replication *will* saturate a shared 10 GbE; 25 GbE for the cluster side stops being a luxury sooner than expected.
- Jumbo frames end-to-end or nowhere — a single 1500-MTU hop in a 9000 path is a future mystery packet-loss bug with your name on it.

## The operational posture

- **Capacity is managed on a trend line,** not at the nearfull warning. Ceph's nearfull (85%) → full (95%) corridor is where clusters go to become read-only at the worst moment. Keep production pools under ~70% raw and order disks on projection.
- **Change one thing at a time, on a weekday, with the previous state written down.** Most small-cluster outages are self-inflicted during "quick" fixes; the runbooks in this repo exist to make the careful path the fast path.
- **Monitor the monitors.** Alerting on `HEALTH_OK` loss (the health script in `scripts/` exists for exactly this), OSD flaps, and backup freshness catches the three failure families that actually happen: disk death, job rot, and slow capacity creep.
