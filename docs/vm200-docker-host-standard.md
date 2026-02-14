# VM200 — Docker Host Standard (Client Track)
# File: docs/vm200-docker-host-standard.md

Purpose:  
Define the standardized build and operating rules for VM200, the first production-style workload VM cloned from VM100.

VM200 is the dedicated Docker host responsible for running all client-standard service stacks behind Traefik.

Scope:  
Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [VM Identity](#vm-identity)
- [Source Template](#source-template)
- [Proxmox Clone Procedure](#proxmox-clone-procedure)
- [Proxmox Settings Standard](#proxmox-settings-standard)
- [Networking Standard](#networking-standard)
- [Directory Standards](#directory-standards)
- [Docker Standard](#docker-standard)
- [Proxy Network Standard](#proxy-network-standard)
- [Service Stack Standard](#service-stack-standard)
- [Security Baseline](#security-baseline)
- [Validation Checklist](#validation-checklist)
- [Backup Policy](#backup-policy)
- [Golden Rules](#golden-rules)
- [Notes](#notes)

---

## Overview

VM200 is a cloned Debian 12 VM based on VM100 (Golden Template).

Role:
- Dedicated Docker host for all service stacks
- Primary reverse proxy host (Traefik)
- Central entry point for all DNS + HTTPS access

VM200 must remain clean, stable, and infrastructure-focused.

---

## VM Identity

Standard VM naming format:

- VMID: `200`
- Name: `docker-host-01`
- OS: Debian 12 (Bookworm)
- Role: Docker host for service stacks

---

## Source Template

VM200 must be cloned from:

- VM100 (Golden Template)

VM100 reference:

- `vm/100-golden.md` (or your VM100 doc path)

---

## Proxmox Clone Procedure

Clone VM100 into VM200 using a full clone:

```bash
qm clone 100 200 --name docker-host-01 --full 1
qm start 200
qm status 200
```

---

## Proxmox Settings Standard

VM200 should inherit VM100 baseline settings.

Minimum expected settings:
- BIOS: `ovmf`
- Machine type: `q35`
- Boot order: `scsi0`
- Secure Boot disabled (`pre-enrolled-keys=0`)
- QEMU Guest Agent enabled
- Serial console enabled (`qm terminal 200` should work)

---

## Networking Standard

VM200 must have stable networking.

Preferred:
- DHCP reservation

Allowed:
- static IP configuration

Minimum requirement:
- VM200 IP must not change after reboots

Example standard:
- VM200 IP: `192.168.1.200`
- Gateway: `192.168.1.1`
- DNS: VM210 (future) or router DNS (lab)

---

## Directory Standards

VM200 follows the platform directory standards:

Stacks live in:

- `/srv/stacks/`

Data lives in:

- `/srv/data/`

Required layout:

```
/srv/stacks/
├── reverse-proxy/
└── immich/

/srv/data/
├── traefik/
└── immich/
```

Example per-stack data layout:

```
/srv/data/immich/
├── library/
├── pgdata/
└── model-cache/
```

This separation keeps stack configs clean and simplifies backups and restores.

---

## Docker Standard

Docker Engine must be installed and functional.

Docker Compose must be available as:

```bash
docker compose version
```

Validate Docker:

```bash
docker run hello-world
docker info
docker ps
```

---

## Proxy Network Standard

VM200 must have the shared proxy network created once:

```bash
docker network create proxy
```

All stacks that need external routing must attach to the `proxy` network.

Traefik standard reference:

- `docs/traefik-standard.md`

---

## Service Stack Standard

Service stacks must be deployed using Docker Compose.

Stacks must follow this structure:

- `stacks/<stackname>/docker-compose.yml`
- `stacks/<stackname>/README.md`
- `stacks/<stackname>/.env.example` (safe template)
- `stacks/<stackname>/.gitignore` (prevents secrets/data commits)

Stacks must not commit real secrets into GitHub.

---

## Security Baseline

VM200 must maintain a minimal and hardened baseline.

Rules:
- keep OS packages minimal
- do not install random non-infrastructure tools
- ensure SSH is hardened (from VM100 baseline)
- Fail2Ban should remain active (from VM100 baseline)

Container security baseline:
- `no-new-privileges:true`
- `cap_drop: ALL`
- log rotation enabled (`10m x 3`)

---

## Validation Checklist

Run after initial deployment and after major changes.

Network checks (VM200):

```bash
ip a
ip route
ping -c 3 192.168.1.1
ping -c 3 1.1.1.1
```

DNS resolution (VM200):

```bash
ping -c 3 google.com
```

SSH access (workstation):

```bash
ssh <user>@<vm200-ip>
```

Docker functionality (VM200):

```bash
docker ps
docker info
docker run hello-world
```

Proxy network (VM200):

```bash
docker network ls | grep proxy
```

---

## Backup Policy

VM200 must be included in Proxmox backup scheduling.

Minimum policy:
- nightly snapshot backups
- compression: `zstd`
- retention: 7 days minimum
- restore testing after major stack deployments

Reference:
- `docs/backup-policy-standard.md`

---

## Golden Rules

- VM200 must remain a dedicated Docker host.
- Do not install unrelated packages.
- All service stacks must use Docker Compose.
- Secrets must never be committed into GitHub.
- All external access must go through Traefik (ports 80/443).
- Containers must not publish service ports directly to the LAN.
- Always document major changes in `docs/decision-log.md`.
- Snapshot VM200 before major deployments/upgrades.
- Backups must be restore-tested after major stack deployments.

---

## Notes

This doc defines the baseline. Service stack implementation details live under:

- `stacks/`

Reverse proxy baseline lives under:

- `stacks/reverse-proxy/`
- `docs/traefik-standard.md`
