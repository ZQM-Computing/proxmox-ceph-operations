# Runbook: replacing a failed or failing Ceph OSD

Replacing an OSD is routine — *if* you let the cluster heal in the right order. The failure mode to avoid is rushing: two OSDs down at once in a 3×-replicated pool with `min_size 2` is how a disk swap becomes an outage.

## Before you touch hardware

1. Confirm the OSD's state: `ceph osd tree` (down/out?), `ceph health detail`.
2. Check the *rest* of the cluster is `HEALTH_OK`-adjacent: all other OSDs up, PGs recovering or clean. **Never start a planned OSD removal while the cluster is already degraded** unless the failing disk is actively making it worse.
3. Read the disk's SMART data on its host. Failing-with-errors and already-dead are different procedures: a still-spinning disk can be drained gracefully; a dead one is removed and backfilled.

## Graceful path (disk alive but failing)

```bash
# 1. Mark the OSD out -- data migrates to remaining OSDs in a controlled way
ceph osd out <id>

# 2. Watch recovery until PGs return to active+clean (or active+undersized
#    only for this OSD's PGs)
ceph -w
ceph pg stat

# 3. Stop and remove the OSD
systemctl stop ceph-osd@<id>          # on the OSD's host
ceph osd purge <id> --yes-i-really-mean-it   # or: ceph osd destroy

# 4. Replace the physical disk, then add the new OSD
ceph-volume lvm create --data /dev/<newdisk>   # on the host (Proxmox: pveceph osd create)
```

## Dead-disk path

Skip the drain: `ceph osd purge` the dead ID, replace hardware, create the new OSD, and let backfill run. Throttle if production I/O suffers: `ceph config set osd osd_max_backfills 1` during business hours, restore afterwards.

## After

- `ceph osd df` — the new OSD is taking data and the utilization spread is converging.
- Update your inventory notes: disk model, install date, host, OSD id. The next replacement (there is always a next one) starts from these notes.
- If the "failure" was actually a cable/backplane issue (SMART clean, errors bursty), bench the disk before trusting the RMA story either way.

## Proxmox note

On Proxmox-managed Ceph, prefer `pveceph` equivalents where they exist (`pveceph osd create/destroy`) so the GUI and the cluster database stay in agreement with the Ceph state.
