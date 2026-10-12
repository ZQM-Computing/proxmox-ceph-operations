# Runbook: upgrade checklist (Proxmox VE + Ceph)

The order matters more than the speed. This checklist is for minor/patch upgrades within a major release line, plus the gates before a major one (e.g., Ceph Reef → Squid, PVE 8 → 9 — always read the vendor's upgrade guide for those; this list wraps it, not replaces it).

## T-minus 1 week

- [ ] Read the release/upgrade notes for both Proxmox and Ceph versions involved; list every "action required" item in your change note.
- [ ] Full backup verification pass: PBS verify job clean, one test restore done ([backups.md](backups.md)).
- [ ] Cluster is `HEALTH_OK` with all PGs `active+clean`. **Do not start an upgrade degraded.**
- [ ] Confirm free space headroom: no OSD above 70%; an upgrade that coincides with a nearfull event is two incidents holding hands.
- [ ] Snapshot/export cluster configuration: `pvecm status`, `/etc/pve` backup, `ceph osd tree`, pool and CRUSH dumps — saved *outside* the cluster.
- [ ] Schedule the window and name the rollback decision-maker (usually: you, but say it out loud anyway).

## Upgrade day — sequence

1. **Ceph first or Proxmox first?** Follow the vendor guide for the specific version pair. The common pattern: upgrade Proxmox nodes one at a time (migrate guests off, upgrade, reboot, migrate back), then Ceph daemons by type (mgr → mon → osd → others), one host at a time, waiting for `HEALTH_OK` between hosts.
2. After each node: check quorum (`pvecm status`), Ceph health, and that the node's OSDs are back `up/in` and PGs are recovering before moving to the next node.
3. Set `noout` during OSD host reboots if the maintenance is quick and you accept the risk window knowingly — and **unset it the moment the host returns** (`ceph osd unset noout`). A forgotten `noout` silently disables self-healing.
4. For Ceph daemon upgrades, use the orchestrated path (`ceph orch upgrade` on Cephadm-managed, or package upgrades in daemon-type order on Proxmox-managed) — never a mixed-version fleet longer than the window requires.

## T-plus 1 day

- [ ] `ceph versions` shows a uniform fleet; no stragglers.
- [ ] `ceph osd require-osd-release` set to the new release when the guide calls for it.
- [ ] Apply the new release's recommended settings only after a soak period, one change at a time.
- [ ] Full health + backup cycle green for 24h before closing the change.
- [ ] Write down what surprised you. That note is the start of next upgrade's checklist.
