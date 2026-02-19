# Reverse Proxy Stack (Traefik)

## Purpose

Provide a standardized reverse proxy layer for all service stacks running on VM200.

This stack is the central entry point for:

- HTTPS routing (TLS termination)
- DNS-based service access (`photos.home.ar`, `vault.home.ar`, etc.)
- Centralized service exposure through one secure layer

**Scope:** Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Directory Layout](#directory-layout)
- [Docker Network Standard](#docker-network-standard)
- [Files Included](#files-included)
- [Deployment](#deployment)
- [Access Standard](#access-standard)
- [Adding New Services](#adding-new-services)
- [Validation](#validation)
- [Golden Rules](#golden-rules)
- [Notes](#notes)

---

## Overview

Traefik is the standard reverse proxy for **HaaS-platformV2**.

All service stacks (Immich, Vaultwarden, monitoring, etc.) must attach to a shared external Docker network named:

- `proxy`

Traefik listens on:

- **80/tcp** (HTTP)
- **443/tcp** (HTTPS)

This enables a clean client-facing experience:

- `https://photos.home.ar`
- `https://vault.home.ar`
- `https://status.home.ar`

---

## Requirements

This stack requires:

- VM200 (Debian 12 Docker Host)
- Docker Engine installed
- Docker Compose installed
- DNS standard implemented (domain resolves to VM200)
- Shared Docker proxy network created (`proxy`)

---

## Directory Layout

Standard directory layout:

- Stack configs live in: `/srv/stacks/`
- Application data lives in: `/srv/data/`

Example layout:

```
/srv/stacks/reverse-proxy/
├── docker-compose.yml
├── traefik.yml
└── dynamic/

/srv/data/traefik/
├── acme.json
└── logs/
```

---

## Docker Network Standard

Traefik requires an external Docker network named:

- `proxy`

Create it once per Docker host:

```bash
docker network create proxy
```

All service stacks must attach to this network so Traefik can route traffic to them.

---

## Files Included

This stack expects the following files:

- `docker-compose.yml`
- `traefik.yml`
- `dynamic/` (optional directory for future rules, middleware, and advanced configs)

Secrets must never be committed into GitHub.

Example:

- `acme.json` must exist on disk but should not be committed.

---

## Deployment

From inside VM200:

```bash
cd /srv/stacks/reverse-proxy
docker compose up -d
```

---

## Access Standard

Traefik is responsible for routing requests based on hostnames.

Example standard hostnames:

- `photos.home.ar` → Immich
- `vault.home.ar` → Vaultwarden
- `status.home.ar` → Uptime Kuma
- `proxy.home.ar` → Traefik dashboard (optional)

All client access must occur using:

- DNS name
- HTTPS

Example:

- `https://photos.home.ar`

---

## Adding New Services

To expose a new service behind Traefik:

1. Attach the service container to the `proxy` network
2. Add Traefik labels to the service container

Example Traefik labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.service.rule=Host(`service.home.ar`)"
  - "traefik.http.routers.service.entrypoints=websecure"
  - "traefik.http.routers.service.tls=true"
  - "traefik.http.services.service.loadbalancer.server.port=1234"
```

Minimum requirements:

- `traefik.enable=true`
- Router rule with correct hostname
- `websecure` entrypoint
- `tls=true`
- Correct container internal port defined

---

## Validation

Confirm Traefik is running:

```bash
docker ps | grep traefik
```

Confirm ports are listening:

```bash
sudo ss -tulnp | grep -E ":(80|443)"
```

Confirm proxy network exists:

```bash
docker network ls | grep proxy
```

Confirm routing works (from workstation):

```bash
curl -I https://photos.home.ar
```

Expected:

- TLS handshake completes
- Response headers returned
- HTTP status 200/301/302 depending on application

---

## Golden Rules

- Traefik is mandatory for all client standard services.
- Services should not expose raw ports unless required for debugging.
- All stacks must join the `proxy` network.
- DNS naming must follow `docs/domain-and-dns-standard.md`.
- No secrets committed into GitHub.
- Reverse proxy config must be documented and reproducible.
- Traefik should remain minimal and stable.

---

## Notes

TLS strategy (Let’s Encrypt vs internal CA) is defined in:

- `docs/domain-and-dns-standard.md`

Traefik should remain stable and standardized.
In your repo, create a quick note like:

stacks/reverse-proxy/README.md

Current working domains:

photos.sotoprivatecloud.com

vault.sotoprivatecloud.com

status.sotoprivatecloud.com

AdGuard IP: 192.168.1.43

Traefik IP: 192.168.1.24

DNS strategy: Split DNS via AdGuard rewrite

ACME working confirmed

“Traefik dashboard published at https://traefik.sotoprivatecloud.com/dashboard/”

“Protected by BasicAuth + LAN allowlist”

“Cert issued by Let’s Encrypt (ACME working)”


All complexity should live inside the service stacks, not the reverse proxy stack.
