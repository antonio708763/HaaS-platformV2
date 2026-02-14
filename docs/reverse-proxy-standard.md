# Reverse Proxy Standard (Client Track)

Purpose:
Define the reverse proxy standard for all HaaS-platformV2 deployments.

The reverse proxy layer is required to provide:
- DNS-based routing
- HTTPS termination
- a single entry point for all client services
- consistent user-facing URLs

Scope:
Client-ready standard track.

---

## Table of Contents

- [Overview](#overview)
- [Standard Proxy Tool](#standard-proxy-tool)
- [Networking Standard](#networking-standard)
- [DNS Standard](#dns-standard)
- [Port Exposure Rules](#port-exposure-rules)
- [Routing Standard](#routing-standard)
- [Service Naming Standard](#service-naming-standard)
- [TLS / HTTPS Standard](#tls--https-standard)
- [Validation Checklist](#validation-checklist)
- [Golden Rules](#golden-rules)

---

## Overview

The reverse proxy is the front door of the platform.

All client services must be accessed through HTTPS hostnames, not raw IP addresses.

Example:

- BAD: http://192.168.1.200:2283
- GOOD: https://photos.home.ar

This improves:
- user experience
- security posture
- documentation clarity
- automation readiness

---

## Standard Proxy Tool

Standard reverse proxy:

- Traefik

Traefik is deployed as the shared reverse proxy stack on VM200.

File location:

- stacks/reverse-proxy/

---

## Networking Standard

The reverse proxy must attach to the external Docker network:

- proxy

This network must exist before any service stack is deployed.

Create once:

    docker network create proxy

All stacks that require external access must attach to this network.

---

## DNS Standard

DNS must resolve all service hostnames to VM200.

Example:

- photos.home.ar → 192.168.1.200
- vault.home.ar → 192.168.1.200
- status.home.ar → 192.168.1.200

DNS requirements are defined in:

- docs/domain-and-dns-standard.md

---

## Port Exposure Rules

VM200 must expose only the following ports long-term:

- 80/tcp
- 443/tcp

All service ports must remain internal.

Containers should not publish ports unless explicitly required for internal debugging.

---

## Routing Standard

Routing is controlled by Traefik labels in each stack's docker-compose.yml.

Each service must define:

- traefik.enable=true
- router hostname rule
- entrypoint websecure
- tls enabled
- internal container port

Example pattern:

    traefik.http.routers.<service>.rule=Host(`photos.home.ar`)
    traefik.http.routers.<service>.entrypoints=websecure
    traefik.http.routers.<service>.tls=true
    traefik.http.services.<service>.loadbalancer.server.port=<port>

---

## Service Naming Standard

DNS names must reflect customer meaning, not software branding.

Preferred examples:

- photos.home.ar
- vault.home.ar
- status.home.ar
- files.home.ar
- media.home.ar

Avoid branding-based hostnames:

- immich.home.ar
- vaultwarden.home.ar
- kuma.home.ar

---

## TLS / HTTPS Standard

HTTPS must always be enabled.

Even for internal-only deployments, HTTPS provides:

- browser compatibility
- modern security expectations
- future readiness

Certificate strategy may evolve, but HTTPS is required.

---

## Validation Checklist

Confirm Traefik is running:

    docker ps

Confirm ports are open:

    ss -tulpn | grep -E "(:80|:443)"

Confirm DNS resolution:

    ping -c 3 photos.home.ar

Confirm routing:

- open https://photos.home.ar in browser
- confirm Immich UI loads

---

## Golden Rules

- All user-facing services must be routed through Traefik.
- DNS must be configured before deploying multiple stacks.
- Only ports 80 and 443 should be exposed.
- Service ports must not be published to LAN.
- Traefik labels are required for every routed service.
- Hostnames must be consistent and documented.
