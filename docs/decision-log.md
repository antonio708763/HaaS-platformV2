# Architecture Decision Records (ADRs)

Purpose:
Record major technical decisions for HaaS-platform using the format:

**Context → Decision → Alternatives → Consequences**

Status values:

- proposed
- accepted
- deprecated
- superseded

---

## ADR-0001: Proxmox VE 9.1 as Host Hypervisor [accepted]

**Date:** 2026-02-07

**Context:**
Stable hypervisor platform required for ZFS, VFIO GPU passthrough, and simple bridge networking for `labcore01` (`192.168.1.123`).

**Decision:**
Use Proxmox VE `9.1.1` (kernel `6.17.2-1-pve`).

**Alternatives:**
- ESXi (paid)
- Ubuntu + KVM (manual build)
- XCP-ng (Xen)

**Consequences:**
- + Proven platform and workflow
- - Current lab storage is a single SSD in DEGRADED state (lab-only risk)

---

## ADR-0002: Single Debian 12 VM for Docker Services [accepted]

**Date:** 2026-02-07

**Context:**
A standardized container host VM is required (`debian12-base`, `192.168.1.50`) with GPU passthrough and template-friendly behavior.

**Decision:**
Use Debian 12 VM (VMID **900**) with:

- machine type: `q35`
- CPU type: `host`
- VFIO passthrough GPU (`01:00.0` / `01:00.1`)

**Alternatives:**
- LXC containers (GPU support limitations)
- Bare-metal Docker (no VM snapshots)

**Consequences:**
- + Easy cloning and reproducibility
- - No live snapshots when GPU passthrough is attached

---

## ADR-0003: GPU Passthrough for VAAPI [accepted]

**Date:** 2026-02-07

**Context:**
Immich requires VAAPI decode support. Lab GPU is Radeon HD 6750 (`PCI 1002:68bf`).

**Decision:**
Passthrough GPU + HDMI audio to VM900 using VFIO.

- Driver: `r600`
- Containers mount `/dev/dri` for VAAPI

**Alternatives:**
- Software decode (CPU-heavy)
- iGPU passthrough (untested)

**Consequences:**
- + VAAPI decode confirmed working
- - Requires `q35`
- - Decode-only capability (limited performance)

---

## ADR-0004: SSH Key-Only Authentication [accepted]

**Date:** 2026-02-09

**Context:**
Eliminate password brute-force risk on `labcore01` and `debian12-base`.

**Decision:**
Use Ed25519 key authentication only.

- Key file: `~/.ssh/haas_proxmox.pub`
- Disable root login
- `PasswordAuthentication=no`

Users:

- `haas-admin@labcore01`
- `user1default@debian12-base`

**Alternatives:**
- Password + fail2ban
- Hybrid key + password

**Consequences:**
- + Eliminates password-based attack surface
- - Requires proper key management and backups

---

## ADR-0005: Proxmox Firewall Baseline [accepted]

**Date:** 2026-02-09

**Context:**
Restrict Proxmox host access to SSH + WebUI only.

**Decision:**
Datacenter firewall rules:

- ACCEPT `22/tcp`
- ACCEPT `8006/tcp`
- DROP all other inbound traffic

**Alternatives:**
- Host-only firewall
- UFW (Debian-only)

**Consequences:**
- + Reduced attack surface
- - Firewall rules require maintenance as services expand

---

## ADR-0006: UFW Firewall on Debian VM [accepted]

**Date:** 2026-02-09

**Context:**
Secure `debian12-base` before deploying reverse proxy and service stacks.

**Decision:**
Enable UFW with default deny, then allow required ports:

- allow `22/tcp` (SSH)
- allow `3001/tcp` (Immich)
- allow `80/tcp` (HTTP reverse proxy)
- allow `443/tcp` (HTTPS reverse proxy)

**Alternatives:**
- nftables (more complex)
- raw iptables rules (manual)

**Consequences:**
- + Simple baseline firewall model
- - Rules will require refinement after proxy deployment

---

## Future ADRs

- ADR-0007: Reverse proxy selection (Traefik vs Nginx Proxy Manager) [proposed]
- ADR-0008: ZFS mirror for v2-client reference build [proposed]
- ADR-0009: Static IP reservations + VLAN segmentation [proposed]
