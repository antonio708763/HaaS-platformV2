# HaaS-platformV2 — Client-Ready Homelab Infrastructure (Standard Track)

This repository documents a **repeatable, client-ready** homelab/server platform built on:

- **Proxmox VE** (virtualization host)
- **Debian 12** Golden VM Template (VM100)
- standardized **backup + restore** operations
- secure defaults (SSH hardening, Fail2Ban, QEMU Guest Agent)

Personal enhancements and experiments (GPU passthrough, VAAPI acceleration, media workloads, etc.) are **not part of the client standard** and live under:

- `addons-research/`

---

## What this repo is (and isn’t)

### This repo is

- a standard build/runbook that can be followed and repeated
- documentation-first and ops-focused (backup/restore, recovery, hygiene)
- designed around stability and reproducibility

### This repo is not

- a “throw everything into one VM” lab notebook
- a personal customization dump (those belong in `addons-research/`)

---

## Reference Architecture

- **Host:** Proxmox VE + ZFS storage
- **Template:** VM100 Debian 12 (UEFI + serial console + hardened baseline)
- **Workloads:** cloned VMs from VM100 (example: VM200 Docker host)
- **Backups:** nightly `vzdump` to dedicated backup storage + restore tests

---

## Repo Structure

```text
HaaS-platformV2/
├── README.md
├── docs/              # Standards + runbooks (client track)
├── host/              # Proxmox host build steps
├── vm/                # VM template + VM roles
└── addons-research/   # Optional experiments (NOT client standard)
