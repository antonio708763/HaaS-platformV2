# Network Setup (Deployment Guide)

Purpose:  
This document provides a step-by-step deployment procedure for implementing the HaaS Tier-1 Network Standard.

This guide is written to be:
- Repeatable
- Deterministic
- Installer-friendly

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Phase 1 - Switch VLAN Configuration](#phase-1---switch-vlan-configuration)
- [Phase 2 - OPNsense Interface Assignment](#phase-2---opnsense-interface-assignment)
- [Phase 3 - VLAN Interface Configuration](#phase-3---vlan-interface-configuration)
- [Phase 4 - DHCP Configuration](#phase-4---dhcp-configuration)
- [Phase 5 - Firewall Rules](#phase-5---firewall-rules)
- [Phase 6 - NAT DNS Enforcement](#phase-6---nat-dns-enforcement)
- [Phase 7 - Validation](#phase-7---validation)
- [Notes](#notes)

---

## Prerequisites

- OPNsense installed and accessible
- Managed switch with VLAN support
- AdGuard DNS server (e.g. 192.168.20.53)
- Access to OPNsense console (critical for recovery)

---

## Phase 1 - Switch VLAN Configuration

Enable 802.1Q VLAN.

Create VLANs:

- VLAN 10 → TRUSTED
- VLAN 20 → SERVERS
- VLAN 30 → IOT
- VLAN 40 → GUEST

Configure ports:

- Port (OPNsense LAN):
  - Tagged: 10,20,30,40
  - PVID: 1 (or default)

- Access ports:
  - TRUSTED device → VLAN 10 (untagged, PVID 10)
  - SERVERS → VLAN 20 (untagged, PVID 20)
  - IOT → VLAN 30 (untagged, PVID 30)
  - GUEST/AP → VLAN 40 (or trunk if AP)

---

## Phase 2 - OPNsense Interface Assignment

Navigate to:

Interfaces → Assignments

Create VLAN interfaces on LAN parent (igb1):

- VLAN 10
- VLAN 20
- VLAN 30
- VLAN 40

Assign interfaces:

- LAN_TRUSTED → VLAN 10
- SERVERS → VLAN 20
- IOT → VLAN 30
- GUEST → VLAN 40

---

## Phase 3 - VLAN Interface Configuration

For each interface:

Enable interface and assign static IP:

- VLAN 10 → 192.168.10.1/24
- VLAN 20 → 192.168.20.1/24
- VLAN 30 → 192.168.30.1/24
- VLAN 40 → 192.168.40.1/24

Save and apply changes.

---

## Phase 4 - DHCP Configuration

Navigate to:

Services → DHCPv4

Enable DHCP per VLAN:

Set ranges:

- TRUSTED → 192.168.10.100 - 192.168.10.199
- SERVERS → 192.168.20.100 - 192.168.20.199
- IOT → 192.168.30.100 - 192.168.30.199
- GUEST → 192.168.40.100 - 192.168.40.199

Set DNS server:

- 192.168.20.53 (AdGuard)

---

## Phase 5 - Firewall Rules

For each VLAN interface:

Create rules (top to bottom):

1. Allow DNS to AdGuard
2. Block RFC1918
3. Block PUBLIC_DNS
4. Block DOH
5. Allow Internet

Apply changes after each VLAN.

---

## Phase 6 - NAT DNS Enforcement

Navigate to:

Firewall → NAT → Port Forward

Create rule per VLAN:

- Interface: VLAN
- Protocol: TCP/UDP
- Source: VLAN net
- Destination: any
- Destination Port: 53
- Redirect Target IP: 192.168.20.53
- Redirect Target Port: 53

Save and apply.

---

## Phase 7 - Validation

Test per VLAN:

### Connectivity
- [ ] Client receives correct IP
- [ ] Gateway reachable
- [ ] Internet works

### DNS Enforcement
- [ ] DHCP DNS works
- [ ] Manual DNS (8.8.8.8) fails

### Isolation
- [ ] Cannot reach other VLANs
- [ ] Can reach internet

---

## Notes

- Always maintain console access during changes
- Never remove active LAN without replacement
- Apply changes incrementally
- Validate after each phase
