# Domain and DNS Standard (Client Track)

Purpose:  
Define standardized DNS naming conventions and domain structure for all HaaS-platformV2 deployments.

A consistent DNS standard enables:
- clean reverse proxy routing
- stable bookmarks for customers
- predictable service onboarding
- simpler troubleshooting
- automation-ready deployments

Scope:  
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
- [Client-Friendly Naming](#client-friendly-naming)
- [Documentation Rules](#documentation-rules)
- [Golden Rules](#golden-rules)

---

## Overview

DNS is required for a client-ready platform.

Without DNS:
- services are accessed by IP + port
- TLS/HTTPS becomes inconsistent
- customer experience feels unfinished

With DNS:
- services are accessed like real apps
- reverse proxy becomes clean
- the platform becomes product-like

Example:

- BAD: `http://192.168.1.200:3001`
- GOOD: `https://photos.home.ar`

---

## Core Naming Philosophy

The platform naming system must be:

- predictable
- short and memorable
- scalable
- automation-friendly
- client-friendly

DNS names should never be random.

---

## Domain Standards

This platform supports two domain types:

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

Public DNS is not required for baseline client deployments.

---

## Recommended Internal Domain

The recommended internal domain is:

- `home.ar`

Reasoning:
- short
- clean
- not a real public TLD
- easy to type
- feels like a real brand product

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

---

## DNS Source Options

DNS must be provided by one of the following.

---

### Option 1: Router DNS (default / easiest)

Client router provides DNS.

Pros:
- zero setup
- already works

Cons:
- limited custom DNS support
- inconsistent across router brands

Router DNS is acceptable for early lab work.

---

### Option 2: Hosts file (allowed for lab only)

Example:

- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Linux/macOS: `/etc/hosts`

Pros:
- simple
- fast

Cons:
- does not scale
- must be repeated on every device

This is not acceptable for real client deployments.

---

### Option 3: Dedicated DNS service (recommended standard)

Use VM210 to provide DNS.

Recommended DNS solutions:
- AdGuard Home
- Pi-hole
- Unbound (optional)

Pros:
- scalable
- clean DNS control
- supports local overrides
- enables real subdomain structure

Cons:
- requires VM210 setup

VM210 becomes the long-term client standard.

---

## DNS Resolution Requirements

The following must resolve correctly:

- Proxmox host
- VM200 Docker host
- reverse proxy endpoints
- all service subdomains

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
| `photos.home.ar` | A | 192.1
