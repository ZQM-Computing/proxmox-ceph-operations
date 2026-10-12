# Runbook: backup discipline

Backups are a *restore* system with a capture habit. These rules come from running production guests whose data (large raster/vector spatial stores) made "just re-download it" a non-answer.

## The rules

1. **Every guest is in a backup job.** No exceptions list kept in someone's head. New guest → same-day job membership → verify in the next morning's report.
2. **Two mechanisms, different failure modes.** Proxmox Backup Server (deduplicated, incremental, verifiable) for the fleet, plus scheduled vzdump archives to a physically separate target for the critical few. PBS and its target must not share a failure domain with the cluster — a PBS VM *on* the cluster it backs up is a diary, not a backup.
3. **Retention is written down.** Example that works: daily × 7, weekly × 4, monthly × 6 for production; daily × 3 for dev guests. Prune jobs run on the PBS datastore, and prune is *verified*, not assumed.
4. **Verify jobs run.** PBS verification re-reads chunks and catches bit-rot early. Schedule it; a failed verify is a page-worthy event, not a log line.
5. **Freshness is monitored, not vibes.** [`scripts/backup_freshness.sh`](../scripts/backup_freshness.sh) flags any guest whose newest archive exceeds the age limit. The PBS equivalent: alert on job duration anomalies and on "last successful backup" per guest in the task log review.
6. **Restores are drilled monthly.** Random guest, isolated network, timed. See [cluster-health.md](cluster-health.md).

## What Ceph replication is not

Ceph's 3× replication protects against *disk and host loss*. It does nothing against deletion, corruption, ransomware, or a bad `rm` replicated faithfully to all three copies in milliseconds. Replication is availability; backups are history. You need both, and confusing them is the most expensive sentence in small-cluster operations.

## Off-cluster copy

At least one backup generation must live outside the cluster room: a removable drive rotation, a small off-site PBS sync, or object storage for the archive tier. For spatial data specifically, the *derived* products (tiles, exports) are regenerable — prioritize the source data, the database dumps, and the VM configurations that would take a weekend to reconstruct.
