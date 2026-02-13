# IP Addressing Standard (Client Track)

Purpose:  
Define standardized IP addressing rules for Proxmox hosts, VMs, and service stacks.

Consistent IP allocation ensures:
- predictable deployments
- cleaner documentation
- easier troubleshooting
- simplified automation
- stable DNS + reverse proxy routing

Scope:  
Client-ready standard track. Applies to all HaaS-platformV2 deployments.

---

## Table of Contents

- [Overview](#overview)
- [Network Baseline](#network-baseline)
- [Subnet Standard](#subnet-standard)
- [Gateway Standard](#gateway-standard)
- [DNS Standard](#dns-standard)
- [Static IP vs DHCP Reservation](#static-ip-vs-dhcp-reservation)
- [IP Allocation Table](#ip-allocation-table)
- [Host IP Standards](#host-ip-standards)
- [VM IP Standards](#vm-ip-standards)
- [Service Access Rules](#service-access-rules)
- [Firewall Notes](#firewall-notes)
- [Documentation Rules](#documentation-rules)
- [Golden Rules](#golden-rules)

---

## Overview

This platform uses predictable IP allocations to avoid:
- random DHCP changes
- broken SSH access
- reverse proxy issues
- confusion during restores

The standard approach is:

- Proxmox hosts use static IPs
- VMs use DHCP reservations or static IPs (depending on environment)
- critical infrastructure always has predictable addresses

---

## Network Baseline

This platform assumes a simple residential LAN design by default.

Baseline network design:

- single subnet
- single router gateway
- no VLANs (until later phases)

VLAN segmentation is a future feature and will be documented separately.

---

## Subnet Standard

Default client subnet:

- `192.168.1.0/24`

Allowed alternatives (if client environment differs):

- `192.168.10.0/24`
- `10.0.0.0/24`

The platform must always document the subnet in use.

---

## Gateway Standard

Default gateway standard:

- `192.168.1.1`

If client router uses a different gateway, document it clearly in:

- `host/network-design.md`

---

## DNS Standard

### Standard DNS sources

DNS should be one of the following:

- Router DNS (typical residential)
- Dedicated internal DNS VM (future standard)
- Pi-hole / AdGuard (optional)

Default standard:

- DNS = router IP (`192.168.1.1`)

---

### Future DNS standard (recommended)

When VM210 exists (DNS VM), DNS should become:

- `192.168.1.210`

At that point, the router should forward DNS requests to VM210.

---

## Static IP vs DHCP Reservation

### Recommended approach (preferred)

Use DHCP reservations whenever possible.

Benefits:
- avoids manual Linux networking config mistakes
- keeps predictable IP addressing
- still allows centralized router control

This is preferred for client environments.

---

### Allowed alternative

Static IP configuration is allowed if:

- router does not support reservations
- router configuration access is restricted
- deployment requires strict static assignment

If static IP is used, it must be documented in the VM's doc.

---

## IP Allocation Table

All deployments must reserve a predictable range for infrastructure.

### Standard IP ranges

| Range | Purpose |
|---|---|
| 192.168.1.1 | Router / Gateway |
| 192.168.1.2–49 | Reserved for network devices (switches/APs/etc.) |
| 192.168.1.50–99 | Reserved for Proxmox hosts |
| 192.168.1.100–199 | Reserved for infrastructure VMs |
| 192.168.1.200–249 | Reserved for service VMs |
| 192.168.1.250–254 | Reserved for emergency / temporary assignments |

This ensures future scaling without IP conflicts.

---

## Host IP Standards

Proxmox host(s) must use static or reserved IPs in the host range.

Standard format:

- `haas-node-01` → `192.168.1.51`
- `haas-node-02` → `192.168.1.52`

Lab example:

- `labcore01` → `192.168.1.123`

Hosts must never use random DHCP addresses.

---

## VM IP Standards

### Required VM mapping

| VM Role | VMID | Standard IP | Notes |
|---|---:|---|---|
| Golden Template | 100 | N/A | Template only, not used as workload |
| Docker Host | 200 | 192.168.1.200 | Primary stack deployment VM |
| DNS VM (future) | 210 | 192.168.1.210 | Internal DNS + domain resolution |
| Monitoring VM (future) | 220 | 192.168.1.220 | Uptime Kuma, Prometheus, Grafana |
| Backup VM (future) | 230 | 192.168.1.230 | Backup tools, sync agents |
| Application VM(s) | 300+ | 192.168.1.3xx | Dedicated workload separation |

---

### VM200 Standard

VM200 must always be assigned:

- `192.168.1.200`

This becomes the assumed target for:

- SSH access
- Docker stack deployments
- reverse proxy routing

---

## Service Access Rules

### Rule: Services must not be accessed by IP long-term

Allowed for debugging:

- `http://192.168.1.200:3001`

Standard usage:

- `https://photos.lab.local`
- `https://vault.lab.local`
- `https://status.lab.local`

---

### Reverse proxy requirement

Once reverse proxy is deployed:

- all services must be accessed by DNS hostname
- ports should not be exposed publicly
- only 80/443 should be reachable from the LAN

---

## Firewall Notes

Firewall rules should align with the IP standard.

Example baseline:

- Proxmox host allows: 22, 8006
- VM200 allows: 22, 80, 443
- internal stack ports should not be exposed to LAN

Firewall enforcement may be done through:

- Proxmox firewall
- VM firewall (ufw)
- Docker network isolation

---

## Documentation Rules

Every deployment must document:

- subnet
- gateway
- host IP
- VM IPs
- DNS source
- DHCP reservation status

Minimum required documentation location:

- `host/network-design.md`
- `docs/ip-addressing-standard.md`

---

## Golden Rules

- Proxmox hosts must never use random DHCP addresses.
- VM200 must always be stable and predictable.
- Use DHCP reservations whenever possible.
- All critical VMs must have reserved or static IPs.
- Services should be accessed by DNS + HTTPS, not IP + port.
- DNS planning must be documented before adding multiple stacks.
- Always update docs when IP changes occur.
