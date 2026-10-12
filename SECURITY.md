# Security policy

## Supported version

Security fixes are applied to the `main` branch. This repository contains documentation and read-only scripts; it is not a hosted service.

## Reporting a problem

Email **zqmcomputing@gmail.com** with the subject `proxmox-ceph-operations security` if you find:

- a script here that **modifies** cluster state despite being documented as read-only (treat that as a security-relevant bug), or
- a procedure whose steps, followed as written, could cause data loss beyond what the runbook warns about.

Please do not open a public issue for a sensitive report. Include the affected file, the impact you observed, and reproduction steps when available.

## Sharing rule

Never paste real cluster output — hostnames, IPs, cluster names, storage layouts — into issues or pull requests for this repository. Scrub first; the patterns matter, your topology details are yours.
