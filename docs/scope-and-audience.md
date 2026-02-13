# Scope and Audience (Standard vs Research)

## Audience

This repository is written for:

- IT roles that need **repeatable infrastructure**
- client-facing deployments where stability > experimentation

---

## Scope: Standard Track (Client-Ready)

The “standard track” includes everything required to build a reliable platform:

- Proxmox host build and maintenance basics
- ZFS storage standards
- VM100 Golden Template (Debian 12 baseline)
- secure defaults (SSH keys, Fail2Ban, guest agent)
- backups + restore verification
- clear VM role separation (Docker host, DNS, monitoring, etc.)

---

## Out of Scope: Research / Personal Enhancements

Anything that introduces non-standard hardware or personal lab goals:

- GPU passthrough / media encoding / ML workloads
- experimental services and stacks that aren’t part of the baseline
- personal-only preferences and customizations

These live in:

- `addons-research/`

---

## Rule

If a client could reasonably deploy it with commodity hardware and minimal risk, it belongs in **Standard**.

If it’s optional, experimental, or personal, it belongs in **addons-research** (or a personal repo later).
