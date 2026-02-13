# Glossary

Purpose:
Define project-specific terminology for consistent communication across documentation, support, and customer-facing materials.

Scope:
Terms used throughout the HaaS-platform repository and future client deployments.

This glossary ensures:

- Technical team uses consistent language
- Customer documentation is clear and precise
- No ambiguity in support tickets or runbooks

---

## Table of Contents

- [Core Concepts](#core-concepts)
  - [HaaS Node](#haas-node)
  - [Service Stack](#service-stack)
  - [Reference Build](#reference-build)
- [Architecture Layers](#architecture-layers)
  - [Host](#host)
  - [Service VM](#service-vm)
  - [Proxy Network](#proxy-network)
- [Hardware Terms](#hardware-terms)
  - [Research Hardware](#research-hardware)
  - [Client SKU](#client-sku)
- [Operational Terms](#operational-terms)
  - [Lab Phase](#lab-phase)
  - [Production Ready](#production-ready)
- [Notes](#notes)
- [Alphabetical Quick Reference](#alphabetical-quick-reference)

---

## Core Concepts

### HaaS Node

A complete deployed appliance (hardware + software) delivered to a customer.

Example:

- Proxmox host + Debian service VM + 3 service stacks = **1 HaaS Node**

In customer-facing language, this may be described as:

- “Your home server box”

---

### Service Stack

A cohesive group of Docker containers that together provide one customer-facing feature.

Example:

- `stacks/immich/` = Immich photo management stack

A service stack typically includes:

- application container(s)
- database container (Postgres / MariaDB)
- cache (Redis) if required
- storage volumes
- Docker networking definitions
- backup/restore procedures

---

### Reference Build

A fully documented, tested, reproducible deployment target intended for production use.

A reference build represents the current “standard” for what a client deployment should look like.

Contrasts with:

- Lab / research builds (experimental hardware, changing configurations)

---

## Architecture Layers

### Host

The bare-metal Proxmox VE hypervisor running on physical hardware.

Role:

- VM management
- ZFS storage backend
- bridge networking (vmbr0)
- backup scheduling

Lab example:

- Proxmox host IP: `192.168.1.123`

Production expectation:

- static IP or DHCP reservation

---

### Service VM

A Debian 12 VM (typically VMID `900+`) hosting Docker service stacks.

Purpose:

- container isolation from host
- snapshot capability
- consistent deployment target across all hardware
- GPU passthrough support (research track)

Networking:

- direct LAN access via `vmbr0` (no NAT)

---

### Proxy Network

A shared Docker network (commonly named `proxy`) used for reverse proxy routing to all service stacks.

Created once per Service VM:

~~~bash
docker network create proxy
~~~

Used by:

- all service stacks
- Traefik / Nginx reverse proxy
- internal routing between containers

---

## Hardware Terms

### Research Hardware

Lab-only components used for architecture validation.

Research hardware may include degraded drives or mixed components and is not considered client-safe.

Current lab example:

- Ryzen 3 2200G
- Radeon HD 6750
- single SSD (ZFS pool DEGRADED)

Status:

- **NOT production suitable**

---

### Client SKU

A standardized hardware bundle sold or deployed to customers.

Example SKUs:

**Basic SKU**
- Intel i3
- 16GB RAM
- 256GB SSD + 2TB HDD

**Plus SKU**
- Intel i5
- 32GB RAM
- 512GB SSD + 4TB HDD + GPU

---

## Operational Terms

### Lab Phase

The research and experimentation stage (example: `v1.0` through `v1.5`).

Goals:

- validate architecture
- document patterns
- test service stacks
- identify failure modes and recovery processes

Characteristics:

- hardware may be non-standard
- configurations may change frequently

---

### Production Ready

Customer-facing deployment quality (typically `v2.0+`).

Production Ready implies:

- redundancy (no single disk failure risk)
- standardized network model
- documented backup and restore process
- stable update process
- predictable monitoring and alerting

Common production requirements:

- ZFS mirror (no single SSD pool)
- VLAN segmentation (optional but recommended)
- automated backups
- stable reverse proxy configuration
- SLA target (example: 99.9%)

---

## Notes

### Terminology Evolution

As the platform matures, language may shift:

- Lab → Research Hardware → Client SKU
- Single VM → Service VM → HaaS Node
- Immich stack → Photo Stack → Private Photos

---

### Customer-Facing Terms (Avoid Technical Jargon)

Recommended translations:

- “HaaS Node” → “Your Home Server Box”
- “Service Stack” → “Photos App” / “Files App”
- “Reference Build” → “Standard Setup”

---

### Support Ticket Categorization

Recommended tags:

- `#hardware` → Client SKU failure
- `#host` → Proxmox issues
- `#vm` → Service VM problems
- `#stack-immich` → Photos app issues
- `#network` → Proxy/reverse proxy problems

---

### Versioned Terms

- `v1.x` = Lab / Research
- `v2.x` = Reference Build
- `v3.x` = Customer Production

---

## Alphabetical Quick Reference

- Client SKU
- HaaS Node
- Host
- Lab Phase
- Production Ready
- Proxy Network
- Reference Build
- Research Hardware
- Service Stack
- Service VM
