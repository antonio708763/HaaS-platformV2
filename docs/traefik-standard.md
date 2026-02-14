# Traefik Standard (Client Track)
# File: docs/traefik-standard.md

Purpose:
Define the standardized Traefik reverse proxy configuration rules used across all HaaS-platformV2 deployments.

This standard ensures:
- consistent stack exposure patterns
- predictable DNS routing
- clean HTTPS access for clients
- repeatable automation-ready deployments
- reduced troubleshooting complexity

Scope:
Client-ready standard track.


---

## Table of Contents

- [Overview](#overview)
- [Core Philosophy](#core-philosophy)
- [Required DNS Dependency](#required-dns-dependency)
- [Required Docker Network Standard](#required-docker-network-standard)
- [Traefik Stack Location](#traefik-stack-location)
- [Traefik Ports Standard](#traefik-ports-standard)
- [Service Exposure Model](#service-exposure-model)
- [Router Naming Standard](#router-naming-standard)
- [Service Naming Standard](#service-naming-standard)
- [Label Standards (Required)](#label-standards-required)
- [HTTPS/TLS Standard](#httpstls-standard)
- [Traefik Dashboard Standard](#traefik-dashboard-standard)
- [Security Standard](#security-standard)
- [Logging Standard](#logging-standard)
- [Deployment Standard](#deployment-standard)
- [Validation Checklist](#validation-checklist)
- [Golden Rules](#golden-rules)
- [Notes](#notes)


---

## Overview

Traefik is the standard reverse proxy for HaaS-platformV2.

Traefik provides:
- HTTP → HTTPS redirect
- TLS termination
- routing based on DNS hostnames
- centralized control of all external exposure

All client-facing services must be accessed using:
- DNS name
- HTTPS
- Traefik routing

Example:

- GOOD: https://photos.home.ar
- BAD:  http://192.168.1.200:2283


---

## Core Philosophy

The reverse proxy is the single gateway into the platform.

Traefik should remain:
- minimal
- stable
- reproducible
- consistent across all deployments

All complexity belongs inside service stacks, not inside Traefik.


---

## Required DNS Dependency

Traefik depends on standardized DNS naming.

This repo standard uses:

- `*.home.ar`

DNS is defined in:

- `docs/domain-and-dns-standard.md`

If DNS is broken, the platform is considered non-functional.


---

## Required Docker Network Standard

All services must join a shared external Docker network:

- `proxy`

This network must exist on VM200 before deploying stacks:

```bash
docker network create proxy
```

This network is the glue that allows Traefik to route to stacks across multiple compose projects.


---

## Traefik Stack Location

Traefik must live in:

- `/srv/stacks/reverse-proxy/`

Traefik persistent data must live in:

- `/srv/data/traefik/`

Example:

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

## Traefik Ports Standard

Traefik is the ONLY stack allowed to expose ports 80/443 to the LAN.

Traefik listens on:

- 80 (HTTP)
- 443 (HTTPS)

Standard docker-compose port bindings:

```yaml
ports:
  - "80:80"
  - "443:443"
```


---

## Service Exposure Model

All services must be exposed using Traefik labels.

Services must NOT publish their internal ports directly to the LAN.

Example of BAD stack design:

```yaml
ports:
  - "3001:3001"
```

Example of GOOD stack design:

```yaml
labels:
  - "traefik.enable=true"
```

Only Traefik is allowed to publish public-facing ports.


---

## Router Naming Standard

Traefik routers must use predictable names.

Standard router naming format:

- `<stackname>`

Examples:

- `immich`
- `vaultwarden`
- `kuma`
- `portainer`
- `grafana`

This ensures clean dashboard visibility and avoids chaos.

Avoid naming routers like:

- `immich-server`
- `photos-router`
- `router-01`


---

## Service Naming Standard

Traefik services must match the router name whenever possible.

Examples:

- router: `immich`
- service: `immich`

This creates predictable config patterns.


---

## Label Standards (Required)

Every stack exposed through Traefik must include these labels.

Minimum required labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<router>.rule=Host(`<dns-name>`)"
  - "traefik.http.routers.<router>.entrypoints=websecure"
  - "traefik.http.routers.<router>.tls=true"
  - "traefik.http.services.<service>.loadbalancer.server.port=<internal-port>"
```

Example (Immich):

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.immich.rule=Host(`photos.home.ar`)"
  - "traefik.http.routers.immich.entrypoints=websecure"
  - "traefik.http.routers.immich.tls=true"
  - "traefik.http.services.immich.loadbalancer.server.port=2283"
```


---

## HTTPS/TLS Standard

Client standard requires HTTPS.

Traefik must enforce:
- HTTPS on all routers
- TLS enabled for all services

HTTP access should redirect to HTTPS.

TLS certificates can be handled by:
- Let's Encrypt ACME (default lab standard)
- internal CA (future option)

Traefik TLS configuration lives in:

- `stacks/reverse-proxy/traefik.yml`
- `stacks/reverse-proxy/dynamic/tls.yml`


---

## Traefik Dashboard Standard

Traefik dashboard is optional.

If enabled:
- it must NOT be open to the public internet
- it should be restricted to LAN access only
- it should be protected with authentication middleware (recommended)

Standard DNS name:

- `proxy.home.ar`

If dashboard is enabled, it should be routed through Traefik itself, not via raw port exposure.


---

## Security Standard

Traefik containers must use hardened settings.

Required:

- `no-new-privileges:true`
- `cap_drop: ALL`
- read-only config mounts where possible
- docker.sock mounted read-only

Example:

```yaml
security_opt:
  - no-new-privileges:true

cap_drop:
  - ALL

volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```


---

## Logging Standard

All Traefik and stack containers must use log rotation.

Standard log driver configuration:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

Traefik access logs should be enabled (recommended).


---

## Deployment Standard

Traefik must be deployed first before any service stacks.

Deploy Traefik:

```bash
cd /srv/stacks/reverse-proxy
docker compose up -d
```

Then deploy stacks such as Immich:

```bash
cd /srv/stacks/immich
docker compose up -d
```


---

## Validation Checklist

Run these checks from VM200.

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

Confirm Traefik can see containers:

```bash
docker logs --tail=200 traefik
```

From your workstation, validate routing:

```bash
curl -I https://photos.home.ar
curl -I https://vault.home.ar
```

Expected:
- 200 / 301 / 302 response
- TLS handshake completes
- Traefik routes correctly


---

## Golden Rules

- Traefik is mandatory for all client-standard stacks.
- Only Traefik exposes ports 80/443 to the LAN.
- All stacks must attach to the `proxy` network.
- All client access must use DNS + HTTPS.
- Service ports must NOT be published directly to the LAN.
- All stacks must include Traefik labels for routing.
- Router and service naming must remain predictable.
- Any changes must be documented in `docs/decision-log.md`.
- If DNS is broken, the platform is non-functional.


---

## Notes

Recommended best practice:

Use wildcard DNS:

- `*.home.ar → 192.168.1.200`

This avoids manual DNS record creation per service stack.

Future improvement:

- VM210 should provide authoritative DNS for `home.ar`
- DHCP should distribute VM210 as default resolver
- router DNS should be bypassed entirely
