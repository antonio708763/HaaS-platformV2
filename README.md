# HaaS-platformV2 — Client-Ready Homelab Infrastructure (Standard Track)

This repository documents a **repeatable, client-ready** homelab/server platform built on:
- **Proxmox VE** (virtualization host)
- **Debian 12** golden VM template (VM100)
- Standardized **backup + restore** operations
- Secure defaults (SSH hardening, Fail2Ban, QEMU Guest Agent)

> Personal enhancements and experiments (GPU passthrough, VAAPI acceleration, media workloads, etc.) are **not part of the client standard** and live under `addons-research/`.

## What this repo is (and isn’t)
**This repo is:**
- A standard build/runbook that can be followed and repeated
- Documentation-first and ops-focused (backup/restore, recovery, hygiene)

**This repo is not:**
- A “throw everything into one VM” lab notebook
- Personal-only customization (that comes later in a separate repo)

## Reference architecture
- **Host:** Proxmox VE + ZFS storage
- **Template:** VM100 Debian 12 (UEFI + serial console + hardened baseline)
- **Workloads:** Cloned VMs from VM100 (e.g., VM200 Docker host)
- **Backups:** Nightly `vzdump` to dedicated backup storage + restore tests

## Repo structure
HaaS-platformV2/
├── README.md
├── docs/ # Standards + runbooks (client track)
├── host/ # Proxmox host build steps
├── vm/ # VM template + VM roles
└── addons-research/ # Optional experiments (NOT client standard)


## Quick start
1. Build the Proxmox host → `host/proxmox-install.md`
2. Configure storage (ZFS) → `host/storage-zfs.md`
3. Build VM100 golden template → `vm/vm100-golden-template.md`
4. Configure backups + restore procedure → `docs/backup-restore-standard.md`
5. Clone VM200 (Docker host) → `vm/vm200-docker-host.md`

## Roadmap (standard track)
- VM200 Docker host baseline
- VM210 DNS baseline
- VM220 monitoring baseline
- VLAN segmentation standard
- “Day-2 operations” checklist (patching, backup verify, restore drill)

**Owner:** Antonio Soto
2) docs/scope-and-audience.md
# Scope and Audience (Standard vs Research)

## Audience
This repository is written for:
- IT roles that need **repeatable infrastructure**
- Client-facing deployments where stability > experimentation

## Scope: Standard Track (Client-ready)
The “standard track” is everything required to build a reliable platform:
- Proxmox host build and maintenance basics
- ZFS storage standards
- VM100 golden template (Debian 12 baseline)
- Secure defaults (SSH keys, Fail2Ban, guest agent)
- Backups + restore verification
- Clear VM role separation (Docker host, DNS, monitoring, etc.)

## Out of scope: Research / Personal Enhancements
Anything that introduces non-standard hardware or “personal lab” goals:
- GPU passthrough / media encoding / ML workloads
- Experimental services and stacks that aren’t part of the baseline
- Personal-only preferences and customizations

These live in: `addons-research/`

## Rule
If a client could reasonably deploy it with commodity hardware and minimal risk, it belongs in **standard**.
If it’s optional, experimental, or personal, it belongs in **addons-research** (or a personal repo later).
3) docs/backup-restore-standard.md
# Backup and Restore Standard (Client Track)

## Goals
- Nightly automated backups
- Clear retention policy
- Proven restore procedure (restore drills)

## Backup storage
Backups are stored on a dedicated backup disk mounted to the Proxmox host (example: `/mnt/backup`)
and exposed to Proxmox as a `dir` storage (example: `backup-hdd`).

## Manual backup (one VM)
Example:
- VMID: 100
- Storage: `backup-hdd`
- Compression: `zstd`
- Mode: `snapshot`

Command:
```bash
vzdump 100 --storage backup-hdd --compress zstd --mode snapshot
Nightly scheduled backups
Create a scheduled job via Proxmox API:

pvesh create /cluster/backup \
  --id nightly-vm100 \
  --storage backup-hdd \
  --mode snapshot \
  --compress zstd \
  --dow mon,tue,wed,thu,fri,sat,sun \
  --starttime 02:00 \
  --vmid 100 \
  --maxfiles 7
Restore verification (required)
At least once after major baseline changes:

Restore the latest backup to a test VMID (ex: 101)

Confirm boot + login prompt

Confirm network comes up

Then delete the test VM

Minimum standard
Backups enabled

Retention set

Restore drill documented + performed
