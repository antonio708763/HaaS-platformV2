# Immich Stack (Photo Management)

Purpose:
Document the Immich photo management stack deployment, configuration, and prerequisites for the HaaS-platform Service VM.

Scope:
Lab/research deployment on Debian 12 Service VM (example: VMID 900).

This stack provides:

- private photo/video backup and organization
- machine learning face recognition and search
- optional hardware-accelerated video processing (VAAPI)

---

## Table of Contents

- [Stack Overview](#stack-overview)
- [Services](#services)
- [Prerequisites](#prerequisites)
- [Networking](#networking)
- [Deployment](#deployment)
- [Configuration](#configuration)
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

- `immich-server`  
  `ghcr.io/immich-app/immich-server:release`

- `immich-microservices`  
  `ghcr.io/immich-app/immich-server:release`

- `immich-machine-learning`  
  `ghcr.io/immich-app/immich-machine-learning:release`

- `redis`  
  `redis:6`

- `database`  
  `pgvector/pgvector:pg14`

---

## Prerequisites

This stack requires:

- Debian 12 Service VM
- Docker Engine installed
- Docker Compose installed
- persistent storage for uploads (`./library`)
- persistent Postgres volume (`pgdata`)

Optional (lab / research):

- GPU passthrough configured
- `/dev/dri` accessible inside the VM
- VAAPI driver functioning (`vainfo` works)

---

## Networking

Networks used:

- `proxy` (external shared network)
  - used for reverse proxy access (Traefik / Nginx Proxy Manager)
- `immich` (internal stack network)
  - used for internal container communication

Create the shared proxy network (only once per Service VM):

~~~bash
docker network create proxy
~~~

---

## Deployment

From inside the Service VM:

~~~bash
cd /srv/HaaS-platform/stacks/immich
cp .env.example .env
~~~

Edit `.env` and set required values.

Deploy:

~~~bash
docker compose up -d
~~~

---

## Configuration

The `.env` file is required.

Required variables:

~~~conf
DB_PASSWORD=your_secure_password
REDIS_HOSTNAME=redis
DB_HOSTNAME=database
~~~

Storage paths:

- `./library` → `/usr/src/app/upload` (photos/videos)

Important rules:

- `DB_PASSWORD` must match the Postgres password configured in the compose file
- secrets must never be committed into the repo

---

## Validation

View logs:

~~~bash
docker compose logs -f immich-server
~~~

Health check:

~~~bash
curl http://immich-server:3001/health
~~~

Expected:

- service responds without errors
- UI accessible through reverse proxy

Example access URL:

- `https://photos.lab.local`

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
- proper group access (`video`, `render`)

Example groups:

- `video` (GID 44)
- `render` (GID 105)

### VAAPI Setup

Example driver:

- `LIBVA_DRIVER_NAME=r600`

Container requirements:

- mount `/dev/dri:/dev/dri`
- include container groups:
  - `44` (video)
  - `105` (render)

### VAAPI Validation (inside VM)

~~~bash
lspci -nnk | grep VGA
vainfo
ls -l /dev/dri
~~~

Expected:

- `card*` devices visible
- kernel driver shows `radeon`
- `vainfo` shows supported decode profiles

---

## Security Notes

Recommended security posture:

- non-root container execution (`1000:1000`)
- `no-new-privileges: true`
- drop unnecessary Linux capabilities (`cap_drop: ALL`)
- log rotation enabled (`max-size`, `max-file`)

---

## Common Commands

Show running containers:

~~~bash
docker ps
~~~

Start the stack:

~~~bash
docker compose up -d
~~~

Stop the stack:

~~~bash
docker compose down
~~~

Pull updates:

~~~bash
docker compose pull
docker compose up -d
~~~

---

## Notes

- Reverse proxy expects external `proxy` network (Traefik or Nginx Proxy Manager).
- This lab stack uses a research GPU; client reference builds should use modern VAAPI-capable hardware.
- If Immich is exposed publicly, additional security hardening is required.

Useful endpoints:

- `GET /health` → Immich server status
- `GET /api/server/info` → system information

Next step:

- deploy reverse proxy configuration
- configure HTTPS certificates
- document backups and restore procedures
