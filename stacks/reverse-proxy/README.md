# Reverse Proxy Stack (Client Track)

Purpose:  
This stack provides the standardized reverse proxy layer for all client-ready service deployments.

The reverse proxy enables:
- HTTPS termination
- clean DNS-based access to services
- unified routing through ports 80/443
- simplified customer onboarding
- isolation of internal service ports

Scope:  
Client-ready standard track. Deployed on **VM200 (Docker host)**.

This reverse proxy is required before deploying most customer-facing stacks.

---

## Table of Contents

- [Overview](#overview)
- [Standard Architecture](#standard-architecture)
- [Stack Location](#stack-location)
- [Networking Standard](#networking-standard)
- [Directory Standards](#directory-standards)
- [Deployment](#deployment)
- [DNS Requirements](#dns-requirements)
- [HTTPS Strategy](#https-strategy)
- [Recommended Reverse Proxy Options](#recommended-reverse-proxy-options)
- [Nginx Proxy Manager Standard (Default)](#nginx-proxy-manager-standard-default)
- [Traefik Standard (Alternative)](#traefik-standard-alternative)
- [Service Routing Standard](#service-routing-standard)
- [Validation Checklist](#validation-checklist)
- [Backup Policy](#backup-policy)
- [Golden Rules](#golden-rules)

---

## Overview

The reverse proxy is the front door of the platform.

Once deployed, all services should be accessed like:

- `https://photos.home.ar`
- `https://vault.home.ar`
- `https://status.home.ar`

Instead of:

- `http://192.168.1.200:3001`

This improves:
- usability
- security
- consistency
- professionalism

---

## Standard Architecture

Standard client architecture:

- VM200 runs Docker Compose stacks
- reverse proxy listens on ports 80/443
- all other services are internal-only
- DNS records point to VM200

Example:

- `photos.home.ar` → `192.168.1.200` → reverse proxy → Immich container port 3001
- `vault.home.ar` → `192.168.1.200` → reverse proxy → Vaultwarden container port 80

---

## Stack Location

Reverse proxy stack must be stored at:

- `/srv/stacks/reverse-proxy/`

This directory is treated as platform infrastructure and must remain stable.

---

## Networking Standard

Reverse proxy must use the shared proxy network.

Standard shared network:

- `proxy`

Create it once:

<pre><code>docker network create proxy</code></pre>

All service stacks must attach to this network.

---

## Directory Standards

Standard stack layout:

- `/srv/stacks/reverse-proxy/`

Optional persistent data layout:

- `/srv/data/reverse-proxy/`

Example:

<pre><code>/srv/stacks/reverse-proxy/
├── docker-compose.yml
└── README.md

/srv/data/reverse-proxy/
├── config/
└── certs/</code></pre>

---

## Deployment

General deployment workflow:

<pre><code>cd /srv/stacks/reverse-proxy
docker compose up -d
docker compose ps</code></pre>

---

## DNS Requirements

DNS must already be functional before deploying reverse proxy.

Minimum required DNS behavior:

- `photos.home.ar` resolves to VM200
- `vault.home.ar` resolves to VM200
- `status.home.ar` resolves to VM200

Example required DNS mapping:

- `*.home.ar` → `192.168.1.200`

If wildcard DNS is not possible, manually define A records.

See:

- `docs/domain-and-dns-standard.md`

---

## HTTPS Strategy

### Lab / internal network standard

For internal client deployments, HTTPS should still be enabled.

Recommended options:

- self-signed certificates (not preferred)
- local CA (recommended)
- Let’s Encrypt DNS challenge (advanced)

---

### Recommended baseline approach

Use reverse proxy + internal DNS + local CA.

This enables:
- trusted HTTPS
- no browser warnings
- professional UX

This may be implemented later as a dedicated "TLS standard" document.

---

## Recommended Reverse Proxy Options

The platform supports two reverse proxy standards.

---

### Option A: Nginx Proxy Manager (recommended default)

Best for:
- simple deployments
- client support workflow
- UI-based configuration
- fast onboarding

This is the preferred standard for client-ready deployments.

---

### Option B: Traefik (advanced alternative)

Best for:
- automation-first environments
- fully GitOps configuration
- scalable service discovery

Traefik is acceptable but requires more operational maturity.

---

## Nginx Proxy Manager Standard (Default)

Nginx Proxy Manager provides:

- reverse proxy routing UI
- HTTPS management
- automatic certificate workflows (when possible)

Recommended for client deployments.

---

### Default ports

NPM requires:

- 80/tcp
- 443/tcp
- 81/tcp (admin UI)

Admin UI example:

- `http://192.168.1.200:81`

---

### Standard admin credentials

Admin credentials must be stored securely offline.

Passwords must never be committed to GitHub.

---

## Traefik Standard (Alternative)

Traefik is a valid option if:

- routing is fully declared in docker-compose labels
- services are deployed in a predictable structure
- configuration is committed cleanly into repo

Traefik is recommended only after standard track is stable.

---

## Service Routing Standard

Once reverse proxy is deployed:

- internal service ports should not be exposed to the LAN
- services should only publish to the proxy network
- reverse proxy becomes the only public-facing entry point

Example:

- Immich runs on internal port 3001
- Reverse proxy routes `photos.home.ar` → `immich-server:3001`

---

### Rule: Every stack must declare a hostname target

Example standards:

| Stack | DNS Name |
|---|---|
| Immich | `photos.home.ar` |
| Vaultwarden | `vault.home.ar` |
| Uptime Kuma | `status.home.ar` |
| Portainer | `portainer.home.ar` |

---

## Validation Checklist

After deployment, confirm:

### Docker network exists

<pre><code>docker network ls | grep proxy</code></pre>

---

### Reverse proxy container is running

<pre><code>docker compose ps
docker logs --tail=50 &lt;container_name&gt;</code></pre>

---

### Ports are listening

<pre><code>ss -tulpn | grep -E "(:80|:443|:81)"</code></pre>

Expected:
- 80 and 443 open
- 81 open (if using NPM)

---

### DNS resolves correctly

From a workstation:

<pre><code>ping -c 3 photos.home.ar
ping -c 3 vault.home.ar
ping -c 3 status.home.ar</code></pre>

Expected:
- all resolve to `192.168.1.200`

---

### Web UI access works

Test in browser:

- `http://192.168.1.200:81`

---

## Backup Policy

Reverse proxy stack must be included in VM200 backup policy.

Minimum standard:
- nightly Proxmox backups of VM200
- retention minimum 7 days
- restore test after major proxy configuration changes

See:

- `docs/backup-restore-standard.md`

---

## Golden Rules

- Reverse proxy must be deployed before exposing services to users.
- Only ports 80/443 should be customer-facing long-term.
- DNS must be stable before adding stacks.
- All stacks must attach to the `proxy` network.
- Never publish database ports to LAN.
- Reverse proxy configuration must be documented after every major change.
- Secrets and admin credentials must never be stored in GitHub.
