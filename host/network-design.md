# Network Design (Lab)

Purpose:
Document how the Proxmox host and service VM(s) are networked, addressed, and accessed.

Scope:
Lab / research environment. Not yet representative of final client reference builds.

---

## Table of Contents

- [Physical Network](#physical-network)
- [Proxmox Bridges](#proxmox-bridges)
- [VM Networking](#vm-networking)
- [IP Addressing](#ip-addressing)
- [DNS](#dns)
- [SSH Access Paths](#ssh-access-paths)
- [Notes](#notes)

---

## Physical Network

- Single LAN subnet: `192.168.1.0/24`
- Default gateway/router: **192.168.1.1**
- Proxmox host connected to LAN via a single physical NIC (`nic0`)

No VLANs are currently in use.

---

## Proxmox Bridges

Primary bridge: **vmbr0**

- `vmbr0` is a Linux bridge providing Layer-2 access to the physical LAN
- Physical NIC `nic0` is enslaved to `vmbr0` (`bridge-ports nic0`)
- STP disabled (`bridge-stp off`)
- Forwarding delay disabled (`bridge-fd 0`)

Host addressing on `vmbr0` (static):

- Proxmox host IP: **192.168.1.123/24**
- Gateway: **192.168.1.1**

Observed interfaces:

- `nic0` is UP and attached to `vmbr0`
- `tap900i0` exists (VMID 900 connected to bridge)

Configuration source:

- `/etc/network/interfaces`

---

## VM Networking

VMID 900 (Debian 12 service VM):

- VM NIC model: `virtio`
- Proxmox bridge: `vmbr0`
- Guest interface name: `enp6s18`
- Guest IP: **192.168.1.50/24** (DHCP / dynamic)
- Default route: **192.168.1.1**

This design provides VMs direct access to the LAN (no NAT).

---

## IP Addressing

Subnet: **192.168.1.0/24**

Known addresses:

- Router/Gateway: **192.168.1.1**
- Proxmox host (`vmbr0`): **192.168.1.123** (static)
- Debian VM (VMID 900): **192.168.1.50** (DHCP)

---

## DNS

Debian VM DNS configuration:

- `nameserver 192.168.1.1`
- `search lan`
- `domain lan`

DNS is provided by the LAN gateway/router (**192.168.1.1**).

Note:

Docker-created networks exist in the guest (example: `docker0` `172.17.0.0/16` and additional `br-*` networks). These are internal to the VM and do not affect LAN addressing.

---

## SSH Access Paths

Access pattern (typical workflow):

1. PC → SSH to Proxmox host (**192.168.1.123**)
2. PC → SSH to Debian VM directly (**192.168.1.50**) OR via Proxmox shell/hop, depending on firewall rules and preference

This is possible because:

- Proxmox host and VM are both on the same LAN subnet via `vmbr0`
- No NAT or port-forwarding is required in the current lab design

---

## Notes

- Lab uses a simple single-bridge design (`vmbr0`) suitable for early research and iteration.
- VM currently uses DHCP; future “reference build” may standardize on static IPs or DHCP reservations.
- DNS is currently router-provided; future reference build may introduce dedicated DNS (example: AdGuard Home / Pi-hole / Unbound) with documented failover behavior.
