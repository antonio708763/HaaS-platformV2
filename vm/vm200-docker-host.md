# VM200 — Docker Host (Client Standard)

Purpose:  
VM200 is the first production-style workload VM cloned from VM100.

This VM acts as the standardized Docker host for deploying service stacks (Immich, Vaultwarden, monitoring, etc.)  
using Docker Compose.

Scope:  
Client-ready standard track (no GPU passthrough, no research hardware assumptions).

---

## Table of Contents

- [Overview](#overview)
- [VM Identity](#vm-identity)
- [Proxmox Clone Procedure](#proxmox-clone-procedure)
- [Proxmox Configuration Standards](#proxmox-configuration-standards)
- [Networking](#networking)
- [Base OS Configuration](#base-os-configuration)
- [Docker Installation](#docker-installation)
- [Docker Compose Baseline](#docker-compose-baseline)
- [Directory Standards](#directory-standards)
- [Validation Checklist](#validation-checklist)
- [Backup Policy](#backup-policy)
- [Golden Rules](#golden-rules)

---

## Overview

VM200 is a cloned Debian 12 VM based on VM100 (Golden Template).

VM200 is the standardized container host used for all Docker-based service stacks.

This VM should remain clean and infrastructure-focused.

---

## VM Identity

- VMID: **200**
- Name: **docker-host-01**
- OS: Debian 12 (Bookworm)
- Source Template: VM100
- Role: Docker host for service stacks

---

## Proxmox Clone Procedure

Clone VM100 into VM200 using a **full clone**:

<pre><code class="language-bash">
qm clone 100 200 --name docker-host-01 --full 1
</code></pre>

Start VM200:

<pre><code class="language-bash">
qm start 200
</code></pre>

Optional: confirm VM is running:

<pre><code class="language-bash">
qm status 200
</code></pre>

---

## Proxmox Configuration Standards

VM200 should inherit VM100 baseline settings.

Minimum expected Proxmox settings:

- BIOS: `ovmf`
- Machine type: `q35`
- Boot order: `scsi0`
- Secure Boot disabled (`pre-enrolled-keys=0`)
- QEMU Guest Agent enabled
- Serial console enabled (`qm terminal 200` should work)

---

## Networking

VM200 must have stable networking.

Recommended approach:

- DHCP reservation (preferred)
- or static IP configuration

Minimum requirement:

- VM IP must not change after reboots

Example standard:

- VM200 IP: `192.168.1.200`
- Gateway: `192.168.1.1`
- DNS: router DNS or internal DNS VM (future)

---

## Base OS Configuration

After first boot, verify:

- SSH works
- `/run/sshd` tmpfiles rule is active
- Fail2Ban is running
- QEMU Guest Agent is running

Confirm services:

<pre><code class="language-bash">
sudo systemctl status ssh
sudo systemctl status fail2ban
sudo systemctl status qemu-guest-agent
</code></pre>

---

## Docker Installation

Install Docker Engine using the official Docker repository method.

After installation, validate Docker:

<pre><code class="language-bash">
docker run hello-world
</code></pre>

Expected:

- Docker pulls and runs the test container successfully.

---

## Docker Compose Baseline

Docker Compose must be available as:

<pre><code class="language-bash">
docker compose version
</code></pre>

If Docker Compose is missing, install the Compose plugin.

---

## Directory Standards

All service stacks should live under:

- `/srv/stacks/`

Example layout:

<pre><code>
/srv/stacks/
├── immich/
├── vaultwarden/
├── uptime-kuma/
└── reverse-proxy/
</code></pre>

Optional data directory:

- `/srv/data/`

Example:

<pre><code>
/srv/data/
├── immich/
├── postgres/
└── backups/
</code></pre>

This keeps stack configs clean and separates application data.

---

## Validation Checklist

Run these checks after deployment.

### Confirm network

<pre><code class="language-bash">
ip a
ip route
ping -c 3 192.168.1.1
ping -c 3 1.1.1.1
</code></pre>

### Confirm DNS resolution

<pre><code class="language-bash">
ping -c 3 google.com
</code></pre>

### Confirm SSH access

From your workstation:

<pre><code class="language-bash">
ssh user@&lt;vm200-ip&gt;
</code></pre>

### Confirm Docker functionality

<pre><code class="language-bash">
docker ps
docker info
docker run hello-world
</code></pre>

---

## Backup Policy

VM200 must be included in Proxmox backup scheduling.

Recommended policy:

- nightly snapshot backup
- compression: `zstd`
- retention: 7 days minimum

Important rule:

- backups must be restore-tested after major stack deployments

---

## Golden Rules

- VM200 must remain a dedicated Docker host.
- Do not install random packages unrelated to hosting services.
- Service stacks must be deployed using Docker Compose.
- Secrets must never be committed into GitHub.
- Always document major changes in `docs/decision-log.md`.
- Snapshot VM200 before major stack deployments or upgrades.
