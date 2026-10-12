# Contributing

The most valuable contributions are corrections earned the hard way: a step that's out of order on your Ceph version, a Proxmox behavior that changed in a point release, a failure mode this repo hasn't met yet.

## Ground rules

1. **Scripts stay read-only.** Anything that mutates a cluster belongs in a runbook as explicit, gated steps — not in automation a reader might run casually.
2. **State your versions.** Proxmox and Ceph behaviors differ across releases; every procedural claim should carry the version context it was verified on.
3. **No real infrastructure details.** Hostnames, IPs, cluster names, and layouts in examples stay generic. Never paste production `ceph status` output without scrubbing identifiers.
4. **Order and gates over brevity.** If a procedure is safe because of its sequence, the sequence is the content — don't compress it away.
5. Scripts must pass `shellcheck` and `bash -n` (CI enforces both).
