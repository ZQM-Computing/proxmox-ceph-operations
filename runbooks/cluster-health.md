# Runbook: cluster health checks

The daily/weekly rhythm that keeps a Proxmox + Ceph cluster boring. Boring is the goal.

## Daily (5 minutes, or automate it)

1. **Ceph health is `HEALTH_OK`.** Anything else has a name and a detail page — read it the day it appears, not the week it cascades.
   ```bash
   ceph health
   ceph health detail        # when not HEALTH_OK
   ```
   Or run [`scripts/ceph_health_check.sh`](../scripts/ceph_health_check.sh), which exits nonzero on any non-OK state so cron/monitoring can alert on it.
2. **Quorum is intact.** `pvecm status` shows the expected vote count and no partitioned nodes.
3. **No stuck placement groups.** `ceph pg stat` — PGs should be `active+clean`. `active+undersized+degraded` that isn't shrinking means recovery is stalled; find out why today.
4. **Backups ran.** Check last night's vzdump/PBS job results, and run [`scripts/backup_freshness.sh`](../scripts/backup_freshness.sh) weekly against the backup store — a job that "succeeds" into a full or unmounted target is the classic silent failure.

## Weekly (15 minutes)

- **OSD utilization spread:** `ceph osd df` — flag any OSD above ~75% or a spread wider than ~15 points between fullest and emptiest. Nearfull OSDs throttle the whole cluster's write path.
- **Pool usage vs. quota:** `ceph df` — know which pool is growing and whether the growth is data or snapshots nobody pruned.
- **Scrub errors:** `ceph health detail` history and `dmesg` on OSD nodes for disk errors. A disk logging SMART warnings is next month's OSD replacement — schedule it on your terms (see [osd-replacement.md](osd-replacement.md)).
- **Guest inventory sanity:** [`scripts/pve_node_report.sh`](../scripts/pve_node_report.sh) — anything running that nobody remembers creating?

## Monthly

- **Restore drill.** Pick one guest at random and restore it to an isolated network. A backup system that has never restored is a hope, not a system. Record the restore time — that's your real RTO data point.
- **Certificate and token review.** Proxmox API tokens and PBS credentials accumulate; revoke what nothing uses.
- **Capacity line.** Plot raw Ceph usage (`ceph df`) month over month. Order disks when the trend crosses 70% *projected*, not when the cluster crosses it actual.

## Red states and first moves

| Symptom | First move |
|---|---|
| `HEALTH_WARN: 1 nearfull osd(s)` | Identify the pool (`ceph osd df`), delete stale snapshots, plan an OSD add — do not rebalance blindly during production hours |
| PGs stuck `inactive` | Check for a down OSD/host in the CRUSH path (`ceph osd tree`) before touching anything else |
| A node drops quorum repeatedly | Corosync network first (cable, switch, MTU on the cluster network) — it is almost never the software |
| Clock skew warnings | NTP on every node; Ceph monitors are unforgiving about skew |
