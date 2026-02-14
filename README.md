# HaaS-platformV2 — Client-Ready Homelab Infrastructure (Standard Track)

This repository documents a **repeatable, client-ready** homelab/server platform built on:

- **Proxmox VE** (virtualization host)
- **Debian 12** Golden VM Template (VM100)
- Standardized **backup + restore** operations
- Secure defaults (SSH hardening, Fail2Ban, QEMU Guest Agent)

Personal enhancements and experiments (GPU passthrough, VAAPI acceleration, media workloads, etc.) are **not part of the client standard** and live under:

- `addons-research/`

---

## What this repo is (and isn’t)

### This repo is

- A standard build/runbook that can be followed and repeated
- Documentation-first and ops-focused (backup/restore, recovery, hygiene)
- Designed around stability and reproducibility

### This repo is not

- A “throw everything into one VM” lab notebook
- A personal customization dump (those belong in `addons-research/`)

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
```

---

## Quick Start (Standard Track)

Follow these in order:

1. Build the Proxmox host  
   → `host/proxmox-setup.md`

2. Configure ZFS storage  
   → `host/storage-zfs.md` *(if present)*

3. Build VM100 Golden Template  
   → `vm/vm100-golden-template.md`

4. Configure backup + restore standard  
   → `docs/backup-policy-standard.md`

5. Clone VM200 Docker Host  
   → `vm/vm200-docker-host-standard.md`

6. Deploy Traefik Reverse Proxy  
   → `stacks/reverse-proxy/README.md`

7. Deploy Immich stack  
   → `stacks/immich/README.md`

---

## Core Standards

These are the rules for the client-ready standard track:

- VM100 is the **single golden template**
- VM200 is the **dedicated Docker host**
- All stacks deploy under `/srv/stacks/`
- All persistent data lives under `/srv/data/`
- Reverse proxy (Traefik) is mandatory
- All client services must use DNS + HTTPS
- Secrets must never be committed into GitHub
- Backups must be restore-tested after major changes

---

## DNS / Domain Standard

This repo uses a consistent internal DNS standard.

Default internal domain:

- `home.ar`

Example service endpoints:

- `https://photos.home.ar`
- `https://vault.home.ar`
- `https://status.home.ar`
- `https://proxy.home.ar`

Reference:

- `docs/domain-and-dns-standard.md`

---

## Documentation Philosophy

This repo is treated like a professional infrastructure runbook.

Rules:

- Every procedure must be reproducible
- Every major change must be documented
- Every stack must include:
  - README.md
  - docker-compose.yml
  - .env.example
  - troubleshooting.md (if needed)
- Every standard must be written clearly enough that a fresh install can follow it

---

## Roadmap (Standard Track)

Planned VM roles:

- VM200 — Docker Host (Traefik + stacks)
- VM210 — DNS (AdGuard Home / Pi-hole)
- VM220 — Monitoring (Uptime Kuma / Grafana)
- VM230 — Backup/Sync (future)

Planned standards:

- VLAN segmentation
- Remote access strategy (future)
- Patch + update runbook
- Restore drill automation

---

## Research / Addons Track

Everything experimental lives under:

- `addons-research/`

Examples:

- GPU passthrough / VAAPI
- media encoding
- high-performance tuning
- experimental stacks

---

## Owner

**Antonio Soto**

---

## License

This project is currently documented for personal and future client deployment use.

License is TBD.
