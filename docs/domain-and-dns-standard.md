# Domain and DNS Standard (Client Track)

## Purpose

Define standardized DNS naming conventions and domain structure for all **HaaS-platformV2** deployments.

A consistent DNS standard enables:

- Clean reverse proxy routing
- Stable bookmarks for customers
- Predictable service onboarding
- Simpler troubleshooting
- Automation-ready deployments

## Scope

Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [Core Naming Philosophy](#core-naming-philosophy)
- [Domain Standards](#domain-standards)
- [Recommended Internal Domain](#recommended-internal-domain)
- [Hostname Standards](#hostname-standards)
- [Service Subdomain Standards](#service-subdomain-standards)
- [DNS Source Options](#dns-source-options)
- [DNS Resolution Requirements](#dns-resolution-requirements)
- [DNS Records Standard](#dns-records-standard)
- [Reverse Proxy Dependency](#reverse-proxy-dependency)
- [Example Deployment Mapping](#example-deployment-mapping)
- [Validation Checklist](#validation-checklist)
- [Client-Friendly Naming](#client-friendly-naming)
- [Documentation Rules](#documentation-rules)
- [Golden Rules](#golden-rules)
- [Notes](#notes)

---

## Overview

DNS is required for a client-ready platform.

Without DNS:

- Services are accessed by IP + port
- TLS/HTTPS becomes inconsistent
- Customer experience feels unfinished

With DNS:

- Services are accessed like real apps
- Reverse proxy becomes clean
- The platform becomes product-like

Example:

- **BAD:** `http://192.168.1.200:3001`
- **GOOD:** `https://photos.home.ar`

---

## Core Naming Philosophy

The platform naming system must be:

- Predictable
- Short and memorable
- Scalable
- Automation-friendly
- Client-friendly

DNS names should never be random.

---

## Domain Standards

This platform supports two domain types.

### Internal-only domain (default standard)

Used only inside the home network.

Example:

- `*.home.ar`

No internet exposure required.

---

### Public domain (optional future standard)

Used if remote access is desired.

Example:

- `photos.clientlastname.com`

This requires:

- DNS provider control
- TLS certificate automation
- remote access tunnel or port forwarding

Public DNS is **not required** for baseline client deployments.

---

## Recommended Internal Domain

The recommended internal domain is:

- `home.ar`

Reasoning:

- Short
- Clean
- Not a real public TLD
- Easy to type
- Feels like a real brand product

Example service names:

- `photos.home.ar`
- `vault.home.ar`
- `status.home.ar`

---

## Hostname Standards

### Proxmox host naming

Proxmox nodes must use:

- `haas-node-01`
- `haas-node-02`

Lab example:

- `labcore01`

---

### VM naming

VM names must follow a predictable role format.

Standard VM names:

- `vm100-golden`
- `vm200-docker-host`
- `vm210-dns`
- `vm220-monitoring`

Or in Proxmox UI naming style:

- `docker-host-01`
- `dns-01`
- `monitoring-01`

---

## Service Subdomain Standards

Services must use clear functional names.

Standard service subdomains:

| Service | DNS Name |
|---|---|
| Immich | `photos.home.ar` |
| Vaultwarden | `vault.home.ar` |
| Uptime Kuma | `status.home.ar` |
| Proxmox UI | `proxmox.home.ar` |
| Portainer | `portainer.home.ar` |
| Grafana | `grafana.home.ar` |
| Jellyfin | `media.home.ar` |
| Nextcloud | `cloud.home.ar` |
| AdGuard / Pi-hole | `dns.home.ar` |
| Reverse Proxy (Traefik Dashboard) | `proxy.home.ar` |

---

### Rule: No vendor branding in DNS

Do not name services like:

- `immich.home.ar`
- `vaultwarden.home.ar`

Instead, name them by what the client understands:

- `photos.home.ar`
- `vault.home.ar`

Clients should never be exposed to backend container names.

---

## DNS Source Options

DNS must be provided by one of the following.

---

### Option 1: Router DNS (default / easiest)

Client router provides DNS.

**Pros:**

- Zero setup
- Already works

**Cons:**

- Limited custom DNS support
- Inconsistent across router brands

Router DNS is acceptable for early lab work.

---

### Option 2: Hosts file (allowed for lab only)

Example locations:

- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Linux/macOS: `/etc/hosts`

**Pros:**

- Simple
- Fast

**Cons:**

- Does not scale
- Must be repeated on every device

This is **not acceptable** for real client deployments.

---

### Option 3: Dedicated DNS service (recommended standard)

Use VM210 to provide DNS.

Recommended DNS solutions:

- AdGuard Home
- Pi-hole
- Unbound (optional)

**Pros:**

- Scalable
- Clean DNS control
- Supports local overrides
- Enables real subdomain structure

**Cons:**

- Requires VM210 setup

VM210 becomes the long-term client standard.

---

## DNS Resolution Requirements

The following must resolve correctly:

- Proxmox host
- VM200 Docker host
- Reverse proxy endpoints
- All service subdomains

Example required behavior:

- `photos.home.ar` → resolves to `192.168.1.200`
- `vault.home.ar` → resolves to `192.168.1.200`
- `status.home.ar` → resolves to `192.168.1.200`

---

## DNS Records Standard

### Default DNS model (reverse proxy pattern)

All services resolve to VM200.

This is because VM200 hosts the reverse proxy.

Example mapping:

| Record | Type | Target |
|---|---|---|
| `photos.home.ar` | A | `192.168.1.200` |
| `vault.home.ar` | A | `192.168.1.200` |
| `status.home.ar` | A | `192.168.1.200` |
| `proxy.home.ar` | A | `192.168.1.200` |

---

## Reverse Proxy Dependency

All client-standard deployments assume:

- Traefik is deployed on VM200
- Traefik is the only system exposing ports `80/443`
- All services route through Traefik using DNS + HTTPS

**Rule:** containers must not publish service ports directly to the LAN.

---

## Example Deployment Mapping

Standard client deployment layout:

- VM200 = Docker host + Traefik reverse proxy
- VM210 = DNS (optional but recommended)
- All services live behind Traefik

Example mapping:

| Component | Location | IP / Name |
|----------|----------|-----------|
| Proxmox host | Bare metal | `192.168.1.123` |
| VM200 Docker Host | Debian 12 VM | `192.168.1.200` |
| Traefik reverse proxy | Docker container | `proxy.home.ar` |
| Immich | Docker stack | `photos.home.ar` |
| Vaultwarden | Docker stack | `vault.home.ar` |
| Uptime Kuma | Docker stack | `status.home.ar` |

---

## Validation Checklist

Run these checks from your workstation.

---

### Confirm DNS resolution

```bash
nslookup photos.home.ar
nslookup vault.home.ar
nslookup proxy.home.ar
```

Expected:

- All records resolve to VM200 IP

---

### Confirm HTTP routing

```bash
curl -I http://photos.home.ar
curl -I http://vault.home.ar
```

Expected:

- HTTP redirects to HTTPS (301/308)

---

### Confirm HTTPS connectivity

```bash
curl -k https://photos.home.ar
curl -k https://vault.home.ar
```

Expected:

- TLS handshake works
- Valid response headers returned

**Note:** Let's Encrypt certificates may take several minutes to issue after first deployment.

---

## Client-Friendly Naming

DNS names must reflect what the client understands.

Good examples:

- `photos.home.ar`
- `vault.home.ar`
- `files.home.ar`
- `status.home.ar`

Bad examples:

- `immich.home.ar`
- `pgvector.home.ar`
- `redis.home.ar`

Clients should never be exposed to backend container names.

---

## Documentation Rules

- All service docs must list the expected DNS hostname
- All stacks must document the Traefik hostname label used
- Any change to DNS naming must be logged in `docs/decision-log.md`
- Standard track documentation must assume DNS exists

---

## Golden Rules

- All stacks must use `.home.ar` naming standard
- DNS must resolve all stack subdomains to VM200
- Reverse proxy must remain the only service exposing ports `80/443`
- Containers must **NOT** publish their service ports directly to the LAN
- All access must occur through Traefik using DNS + HTTPS
- If DNS is broken, the platform is considered non-functional

---

## Notes

Wildcard DNS is preferred.

Example wildcard record:

- `*.home.ar` → `192.168.1.200`

This prevents needing new DNS entries for every new stack.

If wildcard DNS is not possible:

- Every stack must define a dedicated A record

Future improvement (recommended):

- VM210 DNS should own authoritative DNS for `home.ar`
- DHCP should distribute VM210 as the default resolver
- Router DNS should be bypassed entirely
