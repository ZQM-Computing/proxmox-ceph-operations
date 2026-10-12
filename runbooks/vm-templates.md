# Runbook: VM templates with cloud-init

A good template turns "provision a server" into a two-minute, identical-every-time operation. These notes assume Debian/Ubuntu cloud images; the shape transfers.

## Build the template

```bash
# On a cluster node: fetch a cloud image (example: Debian 12 genericcloud)
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

# Create the VM shell and import the disk to Ceph-backed storage
qm create 9000 --name debian12-template --memory 2048 --cores 2 \
    --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm importdisk 9000 debian-12-genericcloud-amd64.qcow2 <ceph-pool-storage>
qm set 9000 --scsi0 <ceph-pool-storage>:vm-9000-disk-0,discard=on,ssd=1
qm set 9000 --boot order=scsi0
qm set 9000 --ide2 <ceph-pool-storage>:cloudinit
qm set 9000 --agent enabled=1
qm set 9000 --serial0 socket --vga serial0

# First boot installs the guest agent properly; then generalize and seal:
#   - apt-get update && apt-get install -y qemu-guest-agent
#   - cloud-init clean, truncate /etc/machine-id, clear shell history
qm template 9000
```

## Clone and personalize

```bash
qm clone 9000 120 --name analytics-01 --full
qm set 120 --ciuser <user> --sshkeys ~/.ssh/authorized_keys --ipconfig0 ip=dhcp
qm set 120 --cores 4 --memory 8192
qm resize 120 scsi0 +40G       # grow before first boot; filesystems expand via cloud-init growpart
qm start 120
```

## Discipline that keeps templates useful

- **One template per OS release**, rebuilt on a cadence (monthly) rather than patched in place — a template with six months of manual updates baked in is just a pet with extra steps.
- **Never convert a working pet VM into the template.** Build from the vendor cloud image so the template's provenance is known.
- **Test the clone path after every rebuild:** clone, boot, SSH in, agent reporting (`qm agent 120 ping`). Two minutes now beats a broken fleet deploy later.
- **Record what's inside** (packages beyond stock, config tweaks) in a `TEMPLATE_NOTES` alongside the build commands — future-you is the audience.
- Keep the template's disk small; clones resize up. Shrinking a disk is the painful direction.
