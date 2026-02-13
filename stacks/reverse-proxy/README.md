# Reverse Proxy Stack (Traefik)

Purpose:
This stack provides the standardized reverse proxy layer for HaaS-platformV2.

Traefik enables:
- HTTPS termination
- DNS-based service routing
- clean access to stacks without exposing internal ports
- a scalable standard for client deployments

Scope:
Client-ready standard track.
Deployed on VM200 (Docker host).

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Directory Standard](#directory-standard)
- [Deployment](#deployment)
- [DNS Requirements](#dns-requirements)
- [Validation Checklist](#validation-checklist)
- [Golden Rules](#golden-rules)

---

## Overview

Traefik is the front door of the platform.

Once deployed, all services should be accessed through DNS + HTTPS:

- https://photos.home.ar
- https://vault.home.ar
- https://status.home.ar

Services should not be accessed long-term using IP:port.

---

## Requirements

VM200 must have:
- Docker Engine installed
- Docker Compose installed
- stable IP address (DHCP reservation or static)

---

## Directory Standard

Traefik stack must live at:

    /srv/stacks/reverse-proxy/

Required files:

    docker-compose.yml
    README.md

---

## Deployment

Create the proxy network once:

    docker network create proxy

Deploy Traefik:

    cd /srv/stacks/reverse-proxy
    docker compose up -d

Confirm it is running:

    docker ps

---

## DNS Requirements

DNS must resolve the following to VM200:

- proxy.home.ar
- photos.home.ar
- vault.home.ar
- status.home.ar

All service subdomains should point to the same VM200 IP because Traefik routes internally.

---

## Validation Checklist

Confirm Traefik container is running:

    docker ps

Confirm ports are listening:

    ss -tulpn | grep -E "(:80|:443)"

Confirm DNS resolves:

    ping -c 3 proxy.home.ar
    ping -c 3 photos.home.ar

Confirm HTTP redirect works:

- Open http://photos.home.ar
- It should redirect to https://photos.home.ar

---

## Golden Rules

- Traefik must be deployed before exposing stacks to users.
- Only ports 80 and 443 should be exposed to the LAN.
- Internal service ports should never be published publicly.
- All stacks must join the external proxy network.
- All client-facing services must be routed by hostname, not IP:port
