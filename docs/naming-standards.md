# Naming Standards (Client Track)

Purpose:  
Define standardized naming conventions for hosts, VMs, service stacks, domains, and internal documentation.

Consistent naming is required to ensure:
- predictable deployments
- easier troubleshooting
- clean documentation
- repeatable automation
- professional client handoffs

Scope:  
Client-ready standard track. Applies to all HaaS-platformV2 deployments.

---

## Table of Contents

- [Overview](#overview)
- [Host Naming Standard](#host-naming-standard)
- [VM Naming Standard](#vm-naming-standard)
- [VMID Allocation Standard](#vmid-allocation-standard)
- [Stack Naming Standard](#stack-naming-standard)
- [Directory Naming Standard](#directory-naming-standard)
- [Domain and Hostname Standards](#domain-and-hostname-standards)
- [Service URL Standards](#service-url-standards)
- [Docker Network Naming](#docker-network-naming)
- [User Account Naming](#user-account-naming)
- [Monitoring Naming Standard](#monitoring-naming-standard)
- [Documentation File Naming](#documentation-file-naming)
- [Golden Rules](#golden-rules)

---

## Overview

The platform is built around predictable and repeatable infrastructure.

A consistent naming standard prevents:

- confusing VM inventory
- broken automation
- inconsistent DNS records
- unclear troubleshooting steps

This standard must be followed even in lab deployments.

---

## Host Naming Standard

Proxmox hosts must follow:

`haas-node-XX`

Examples:

- `haas-node-01`
- `haas-node-02`

Lab-specific naming may also include:

- `labcore01`
- `labcore02`

Client-ready naming should always use the `haas-node-XX` format.

---

## VM Naming Standard

VM names must follow:

`<role>-<number>`

Examples:

- `docker-host-01`
- `dns-01`
- `monitoring-01`
- `backup-agent-01`

This keeps the Proxmox UI readable and role-focused.

---

## VMID Allocation Standard

VMIDs must be predictable and grouped by function.

### Reserved ranges

| VMID Range | Purpose |
|---|---|
| 100–199 | Golden templates |
| 200–299 | Core infrastructure VMs |
| 300–399 | Service VMs (apps/stacks) |
| 400–499 | Monitoring / logging / metrics |
| 500–599 | Backup and recovery tooling |
| 900–999 | Research / lab / experimental |

---

### Required assignments

- VM100 = Debian 12 Golden Template (Standard Track)
- VM200 = Docker Host (Standard Track)

---

## Stack Naming Standard

Stacks must be named based on the service.

Examples:

- `reverse-proxy`
- `uptime-kuma`
- `immich`
- `vaultwarden`
- `nextcloud`
- `jellyfin`

Stack names must match directory names.

Avoid ambiguous names like:

- `photos`
- `media`
- `app1`

Instead use the actual upstream project name.

---

## Directory Naming Standard

Stacks must be stored under:

<pre><code>
/srv/stacks/
</code></pre>

Each stack gets its own folder:

<pre><code>
/srv/stacks/<stack-name>/
</code></pre>

Example:

<pre><code>
/srv/stacks/reverse-proxy/
</code></pre>

All persistent application data should be stored under the stack directory unless explicitly separated.

---

## Domain and Hostname Standards

### Standard internal domain

For lab and client deployments, use:

- `.local` for internal DNS
- or a dedicated internal domain such as `.lan`

Standard examples:

- `home.local`
- `haas.local`
- `client.local`

---

### Hostname standard for services

Service hostnames must follow:

`<service>.<domain>`

Examples:

- `status.lab.local`
- `photos.lab.local`
- `vault.lab.local`
- `proxy.lab.local`

---

## Service URL Standards

All services must be accessed through reverse proxy URLs.

Examples:

- `https://status.lab.local`
- `https://photos.lab.local`
- `https://vault.lab.local`

Direct port access should be avoided once reverse proxy is deployed.

Avoid exposing URLs like:

- `http://192.168.1.200:3001`

Those should only be used for debugging.

---

## Docker Network Naming

The shared reverse proxy network must always be named:

`proxy`

This is a required platform standard.

Create once:

<pre><code class="language-bash">
docker network create proxy
</code></pre>

All stacks requiring reverse proxy routing must join the proxy network.

---

## User Account Naming

### Proxmox host accounts

Standard administrative account:

- `haas-admin`

Avoid using generic usernames like:

- `admin`
- `root`
- `user`

---

### VM accounts

Standard Linux user:

- `haas-admin`

SSH access must be key-based.

---

## Monitoring Naming Standard

Monitoring checks must follow:

`[Layer] - [Node] - [Service]`

Examples:

- `HOST - haas-node-01 - Ping`
- `HOST - haas-node-01 - Proxmox WebUI`
- `VM - VM200 - SSH`
- `STACK - Reverse Proxy - HTTPS`
- `STACK - Uptime Kuma - HTTP`
- `STACK - Immich - HTTPS`

---

## Documentation File Naming

Documentation must follow consistent naming:

- lowercase
- hyphen-separated
- clear meaning

Good examples:

- `backup-restore-standard.md`
- `monitoring-standard.md`
- `naming-standards.md`

Avoid:

- `BackupDocFINAL.md`
- `doc1.md`
- `notes.md`

---

## Golden Rules

- Naming must be consistent even in lab builds.
- VMID ranges must be respected.
- Every stack name must match its directory name.
- Reverse proxy hostnames must be predictable.
- Do not expose service ports directly once proxy is deployed.
- `proxy` Docker network name is mandatory and universal.
- Standard track must remain clean and automation-friendly.
