# Immich Stack (Photo Management)

Purpose:
Document the Immich photo management stack deployment, configuration, and prerequisites for the HaaS-platformV2 Docker host (VM200).

Scope:
Client-ready deployment using:
- VM200 (Debian 12 Docker host)
- Traefik reverse proxy stack
- DNS-based routing

This stack provides:
- private photo/video backup and organization
- machine learning face recognition and search
- optional hardware-accelerated video processing (VAAPI) (research track only)

---

## Table of Contents

- [Stack Overview](#stack-overview)
- [Services](#services)
- [Prerequisites](#prerequisites)
- [Networking](#networking)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Access (Client Standard)](#access-client-standard)
- [Validation](#validation)
- [Hardware Acceleration (VAAPI)](#hardware-acceleration-vaapi)
- [Security Notes](#security-notes)
- [Common Commands](#common-commands)
- [Notes](#notes)

---

## Stack Overview

Immich is a self-hosted photo and video management platform designed as a privacy-first alternative to cloud photo services.

This stack is intended to be deployed on VM200 and accessed through Traefik using DNS + HTTPS.

---

## Services

Containers used by this stack:

- immich-server
  - ghcr.io/immich-app/immich-server:release

- immich-microservices
  - ghcr.io/immich-app/immich-server:release

- immich-machine-learning
  - ghcr.io/immich-app/immich-machine-learning:release

- redis
  - redis:6

- database
  - pgvector/pgvector:pg14

---

## Prerequisites

This stack requires:

- Debian 12 VM (VM200 Docker host standard)
- Docker Engine installed
- Docker Compose installed
- persistent storage for uploads
- persistent Postgres storage

---

### Required Docker Network: proxy

Immich must attach to the shared external Docker network used by Traefik.

- Network name: proxy
- Type: external

This network must be created once on VM200 before deploying stacks:

    docker network create proxy

---

## Networking

Networks used:

- proxy (external shared network)
  - used for Traefik reverse proxy routing

- immich (internal stack network)
  - used for internal container communication

The shared proxy network must exist before deploying Immich:

    docker network create proxy

---

## Deployment

From inside VM200:

    cd /srv/stacks/immich
    cp .env.example .env

Edit `.env` and set required values.

Deploy the stack:

    docker compose up -d

---

## Configuration

The `.env` file is required.

Required variables (minimum baseline):

    DB_PASSWORD=your_secure_password
    REDIS_HOSTNAME=redis
    DB_HOSTNAME=database

Storage paths:

- /srv/data/immich/library → /usr/src/app/upload

Important rules:

- DB_PASSWORD must match the Postgres password expected by the database container
- secrets must never be committed into GitHub

---

## Access (Client Standard)

Immich must be accessed through the reverse proxy using DNS + HTTPS.

Standard URL:

- https://photos.home.ar

Immich should not be accessed long-term using IP:port.

Reverse proxy routing is handled by Traefik labels inside:

- stacks/immich/docker-compose.yml

Reverse proxy stack reference:

- stacks/reverse-proxy/

DNS requirements reference:

- docs/domain-and-dns-standard.md

---

## Validation

View logs:

    docker compose logs -f immich-server

Check container status:

    docker compose ps

Health check (from inside VM200):

    curl http://immich-server:2283/api/server/ping

Expected output:

    pong

If the reverse proxy is configured correctly, the UI should load at:

- https://photos.home.ar

---

## Hardware Acceleration (VAAPI)

This section applies only to lab/research builds.

Client-ready standard track does not require GPU passthrough.

---

### GPU Requirements

Example lab GPU:

- AMD Radeon HD 6750 (Juniper PRO)
- PCI ID: 1002:68bf

Required inside VM:

- VFIO passthrough configured
- /dev/dri device nodes available
- proper group access (video, render)

Example groups:

- video (GID 44)
- render (GID 105)

---

### VAAPI Setup

Example driver:

- LIBVA_DRIVER_NAME=r600

Container requirements:

- mount /dev/dri:/dev/dri
- include container groups:
  - 44 (video)
  - 105 (render)

---

### VAAPI Validation (inside VM)

    lspci -nnk | grep VGA
    vainfo
    ls -l /dev/dri

Expected:

- card* devices visible
- kernel driver shows radeon
- vainfo shows supported decode profiles

---

## Security Notes

Recommended security posture:

- non-root container execution (1000:1000)
- no-new-privileges: true
- drop unnecessary Linux capabilities (cap_drop: ALL)
- log rotation enabled (max-size, max-file)

---

## Common Commands

Show running containers:

    docker ps

Start the stack:

    docker compose up -d

Stop the stack:

    docker compose down

Pull updates:

    docker compose pull
    docker compose up -d

---

## Notes

- Reverse proxy requires the external proxy Docker network.
- Traefik routing is configured using docker-compose labels.
- Client deployments should prioritize stability and simple DNS naming.
- VAAPI acceleration is optional and belongs under addons-research when used.

Useful endpoints:

- GET /api/server/ping → connectivity check (pong response)
- GET /health → Immich server health

Next steps:

- deploy reverse proxy configuration (Traefik)
- configure trusted HTTPS certificates (future standard)
- document backups and restore procedures
