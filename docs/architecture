
# Tier 1 Standard Network Blueprint
HaaS Platform V2

## Purpose

This document defines the **standard network architecture** for the Tier 1 Sovereign Infrastructure Platform.

The goal of this blueprint is to provide a **repeatable, secure, and supportable network design** that can be deployed identically across all client installations.

Design priorities:

- Simplicity for end users
- Strong network segmentation
- Privacy-first architecture
- Local ownership of infrastructure
- Easy documentation and automation

This design supports **1–5 users in a residential environment**.

---

# Network Architecture Overview

The Tier 1 model uses **VLAN segmentation** to separate trusted devices, infrastructure services, IoT devices, guests, and management interfaces.

This ensures compromised or untrusted devices cannot access critical infrastructure.

| VLAN | Name | Purpose |
|-----|-----|-----|
| 10 | Trusted LAN | Primary user devices |
| 20 | Servers | Infrastructure and services |
| 30 | IoT | Smart devices and untrusted hardware |
| 40 | Guest | Internet-only visitor access |
| 50 | Management | Administrative interfaces |

---

# VLAN 10 — Trusted LAN

### Purpose
Primary network for trusted user devices.

### Network
```
192.168.10.0/24
```

### Gateway
```
192.168.10.1
```

### Typical Devices

- laptops
- desktops
- phones
- tablets

### Default Policy

Allowed:

- Internet access
- DNS services
- Access to approved internal services

Blocked:

- Direct access to management network

### SSID

```
Home
```

---

# VLAN 20 — Servers

### Purpose

Hosts infrastructure and self‑hosted services.

### Network

```
192.168.20.0/24
```

### Gateway

```
192.168.20.1
```

### Typical Systems

- Proxmox host
- DNS servers
- Docker hosts
- internal services
- reverse proxy
- automation services

### Default Policy

Allowed:

- Internet access for updates
- DNS services

Accessible from:

- Trusted LAN for approved services

Blocked from:

- Guest network
- IoT network

---

# VLAN 30 — IoT

### Purpose

Isolates smart devices that are not trusted.

### Network

```
192.168.30.0/24
```

### Gateway

```
192.168.30.1
```

### Typical Devices

- smart TVs
- streaming boxes
- smart plugs
- smart cameras
- assistants
- appliances

### Default Policy

Allowed:

- Internet access
- DNS

Blocked:

- Servers VLAN
- Management VLAN
- Trusted LAN

### SSID

```
IoT
```

---

# VLAN 40 — Guest

### Purpose

Provides safe internet access for visitors.

### Network

```
192.168.40.0/24
```

### Gateway

```
192.168.40.1
```

### Typical Devices

- guest phones
- guest laptops

### Default Policy

Allowed:

- Internet access
- DNS

Blocked:

- All internal networks

### SSID

```
Guest
```

---

# VLAN 50 — Management

### Purpose

Dedicated administrative network for infrastructure control.

### Network

```
192.168.50.0/24
```

### Gateway

```
192.168.50.1
```

### Typical Systems

- router management
- switch management
- access point management
- administrative workstations

### Default Policy

Highly restricted.

Allowed:

- administration of infrastructure

Blocked:

- Guest network
- IoT network

---

# Standard Infrastructure IP Layout

| Device | Address |
|------|------|
| Router | 192.168.50.1 |
| Proxmox Host | 192.168.20.10 |
| DNS Server 1 | 192.168.20.53 |
| DNS Server 2 | 192.168.20.54 |
| Switch | 192.168.50.2 |
| Access Point | 192.168.50.10 |

---

# Default DNS Configuration

All networks use the internal DNS servers:

```
192.168.20.53
192.168.20.54
```

DNS servers forward encrypted queries upstream using **DNS‑over‑HTTPS (DoH)**.

---

# Firewall Philosophy

Default posture is **deny by default between VLANs**.

Permitted traffic is explicitly allowed.

Examples:

| Source | Destination | Policy |
|------|------|------|
| Trusted LAN | Internet | Allow |
| Trusted LAN | Servers | Allow specific services |
| IoT | Internet | Allow |
| IoT | Servers | Block |
| Guest | Internet | Allow |
| Guest | Internal networks | Block |

---

# Hardware Layout

Typical Tier 1 deployment:

```
Internet
   │
ISP Modem
   │
OPNsense Router
   │
Managed Switch (VLAN capable)
   │
Devices / Access Point / Servers
```

Wireless networks are delivered by a VLAN‑aware access point.

---

# Wireless SSID Layout

| SSID | VLAN |
|-----|-----|
| Home | VLAN 10 |
| IoT | VLAN 30 |
| Guest | VLAN 40 |

---

# Design Principles

This architecture prioritizes:

- privacy
- resilience
- security
- reproducibility
- minimal support complexity

Every installation should follow this exact structure to ensure consistent documentation and automated deployment in future versions.

---

# Future Enhancements

Potential future improvements include:

- automated provisioning scripts
- centralized configuration templates
- automatic firewall rule generation
- VLAN‑aware provisioning wizard

---

End of Document
