# Reverse Proxy Stack (Traefik)

Purpose:  
Provide a standardized reverse proxy layer for all service stacks running on VM200.

This stack is the central entry point for:

- HTTPS routing (TLS termination)
- DNS-based service access (photos.home.ar, vault.home.ar, etc.)
- Centralized service exposure through one secure layer

Scope:  
Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Directory Layout](#directory-layout)
- [Docker Network Standard](#docker-network-standard)
- [Deployment](#deployment)
- [Access Standard](#access-standard)
- [Adding New Services](#adding-new-services)
- [Validation](#validation)
- [Golden Rules](#golden-rules)
- [Notes](#notes)

---

## Overview

Traefik is used as the standard reverse proxy for HaaS-platformV2.

All stacks (Immich, Vaultwarden, monitoring, etc.) must attach to a shared Docker network:

- `proxy`

Traefik listens on ports:

- 80 (HTTP)
- 443 (HTTPS)

---

## Requirements

This stack requires:

- Debian 12 VM200 Docker Host
- Docker Engine installed
- Docker Compose installed
- DNS standard implemented (domain resolves to VM200)
- Shared Docker proxy network created

---

## Directory Layout

Standard directory layout:

- Stack configs live in: `/srv/stacks/`
- App data lives in: `/srv/data/`

Example layout:

    /srv/stacks/reverse-proxy/
    ├── docker-compose.yml
    ├── traefik.yml
    └── dynamic/

    /srv/data/traefik/
    ├── acme.json
    └── logs/

---

## Docker Network Standard

Traefik requires an external Docker network called:

- `proxy`

Create it once:

    docker network create proxy

All service stacks must attach to this network so Traefik can route traffic to them.

---

## Deployment

From VM200:

    cd /srv/stacks/reverse-proxy
    docker compose up -d

---

## Access Standard

Traefik is responsible for routing requests based on hostnames.

Example standard hostnames:

- photos.home.ar → Immich
- vault.home.ar → Vaultwarden
- kuma.home.ar → Uptime Kuma

All services must be accessed using:

- DNS name
- HTTPS

Example:

- https://photos.home.ar

---

## Adding New Services

To expose a service behind Traefik:

1. Attach the stack container to the `proxy` network
2. Add Traefik labels

Example Traefik labels:

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.service.rule=Host(`service.home.ar`)"
      - "traefik.http.routers.service.entrypoints=websecure"
      - "traefik.http.routers.service.tls=true"
      - "traefik.http.services.service.loadbalancer.server.port=1234"

---

## Validation

Confirm Traefik is running:

    docker ps | grep traefik

Confirm ports are listening:

    sudo ss -tulnp | grep -E ":(80|443)"

Confirm proxy network exists:

    docker network ls | grep proxy

Confirm routing works (from workstation):

    curl -I https://photos.home.ar

---

## Golden Rules

- Traefik is mandatory for all client standard services.
- Services should not expose raw ports unless required for debugging.
- Stacks must join the `proxy` network.
- DNS must be standardized.
- No secrets committed into GitHub.
- Traefik config must be documented and reproducible.

---

## Notes

TLS strategy (Let’s Encrypt vs internal CA) is defined in:

- `docs/domain-and-dns-standard.md`

Traefik should remain minimal and stable.
All complexity should live inside service stacks, not the reverse proxy stack.
