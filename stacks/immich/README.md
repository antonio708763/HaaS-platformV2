# Immich Stack (Photo Management)

Purpose:  
Document the Immich photo management stack deployment, configuration, and prerequisites for the HaaS-platform Docker Host VM (VM200).

Scope:  
Client-ready standard track using **Traefik reverse proxy** and DNS-based access.

This stack provides:

- Private photo/video backup and organization
- Machine learning face recognition and search
- Optional hardware-accelerated video processing (VAAPI)

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

---

## Services

Containers used by this stack:

- **immich-server**  
  `ghcr.io/immich-app/immich-server:release`

- **immich-microservices**  
  `ghcr.io/immich-app/immich-server:release`

- **immich-machine-learning**  
  `ghcr.io/immich-app/immich-machine-learning:release`

- **redis**  
  `redis:6`

- **database**  
  `pgvector/pgvector:pg14`

---

## Prerequisites

This stack requires:

- Debian 12 Docker Host VM (example: VM200)
- Docker Engine installed
- Docker Compose installed
- `.env` file created from `.env.example`
- Persistent storage for uploads (`./library`)
- Persistent Postgres volume (`pgdata`)

### Required Docker Network: `proxy`

Immich must attach to the shared external Docker network used by Traefik.

- Network name: `proxy`
- Type: external

This network must be created once on VM200 before deploying stacks:

    docker network create proxy

Optional (research only):

- GPU passthrough configured
- `/dev/dri` accessible inside the VM
- VAAPI driver functioning (`vainfo` works)

---

## Networking

Networks used:

- **proxy** (external shared network)  
  Used for reverse proxy access (Traefik)

- **immich** (internal stack network)  
  Used for internal container communication

Create the shared proxy network (only once per Docker host VM):

    docker network create proxy

---

## Deployment

From inside VM200:

    cd /srv/stacks/immich
    cp .env.example .env

Edit `.env` and set required values.

Deploy:

    docker compose up -d

---

## Configuration

The `.env` file is required.

Required variables:

    DB_PASSWORD=your_secure_password
    REDIS_HOSTNAME=redis
    DB_HOSTNAME=database

Storage paths:

- `./library` → `/usr/src/app/upload` (photos/videos)

Important rules:

- `DB_PASSWORD` must match the Postgres password configured in the compose file
- Secrets must never be committed into GitHub

---

## Access (Client Standard)

Immich must be accessed through the reverse proxy using DNS + HTTPS.

Standard URL example:

- `https://photos.home.ar`

Immich should not be accessed long-term using raw IP:port.

Example (debug only):

- `http://192.168.1.200:2283`

Reverse proxy routing is handled by Traefik labels inside:

- `stacks/immich/docker-compose.yml`

Reverse proxy stack reference:

- `stacks/reverse-proxy/`

---

## Validation

View logs:

    docker compose logs -f immich-server

Health check:

    curl http://immich-server:3001/health

Expected:

- Service responds without errors
- UI is accessible through Traefik reverse proxy

Example access URL:

- `https://photos.home.ar`

---

## Hardware Acceleration (VAAPI)

This is optional and applies to lab/research builds.

### GPU Requirements

Example lab GPU:

- AMD Radeon HD 6750 (Juniper PRO)
- PCI ID: `1002:68bf`

Required inside VM:

- VFIO passthrough configured
- `/dev/dri` device nodes available
- Proper group access (`video`, `render`)

Example groups:

- `video` (GID 44)
- `render` (GID 105)

---

### VAAPI Setup

Example driver:

- `LIBVA_DRIVER_NAME=r600`

Container requirements:

- Mount `/dev/dri:/dev/dri`
- Include container groups:
  - `44` (video)
  - `105` (render)

---

### VAAPI Validation (inside VM)

    lspci -nnk | grep VGA
    vainfo
    ls -l /dev/dri

Expected:

- `card*` devices visible
- Kernel driver shows `radeon`
- `vainfo` shows supported decode profiles

---

## Security Notes

Recommended security posture:

- Non-root container execution (`1000:1000`)
- `no-new-privileges: true`
- Drop unnecessary Linux capabilities (`cap_drop: ALL`)
- Log rotation enabled (`max-size`, `max-file`)

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

- Reverse proxy expects external `proxy` network (Traefik).
- This lab stack uses a research GPU; client reference builds should use modern VAAPI-capable hardware.
- If Immich is exposed publicly, additional security hardening is required.

Useful endpoints:

- `GET /health` → Immich server status  
- `GET /api/server/info` → System information

Next steps:

- Confirm Traefik routing
- Configure DNS records
- Document backups and restore procedures
