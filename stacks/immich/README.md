# Immich Stack (Photo Management)

## Purpose

Document the Immich photo management stack deployment, configuration, and prerequisites for the **HaaS-platformV2 Docker Host VM (VM200)**.

This is written for the **client-ready standard track** using:

- **Traefik reverse proxy** (`stacks/reverse-proxy/`)
- **DNS-based access** (example: `photos.home.ar`)

This stack provides:

- Private photo/video backup and organization
- Machine learning face recognition and search
- Optional hardware-accelerated video processing (VAAPI) *(research only)*

---

## Table of Contents

- [Overview](#overview)
- [Services](#services)
- [Prerequisites](#prerequisites)
- [Directory Standards](#directory-standards)
- [Networking](#networking)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Access Standard](#access-standard)
- [Validation](#validation)
- [Updates](#updates)
- [Hardware Acceleration](#hardware-acceleration)
- [Security Notes](#security-notes)
- [Common Commands](#common-commands)
- [Notes](#notes)

---

## Overview

Immich is a self-hosted photo and video management platform designed as a privacy-first alternative to cloud photo services.

In the HaaS-platformV2 **standard track**, Immich is deployed on **VM200** and is accessed **only through Traefik** using **DNS + HTTPS**.

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

- VM200 (Debian 12 Docker Host)
- Docker Engine installed
- Docker Compose installed
- Traefik reverse proxy stack deployed (`stacks/reverse-proxy/`)
- DNS standard implemented (`docs/domain-and-dns-standard.md`)
- `.env` file created on VM200 from `.env.example` *(do not commit `.env`)*
- Persistent storage for uploads
- Persistent Postgres data directory

---

## Directory Standards

Standard directories on VM200:

- Stack configs: `/srv/stacks/`
- App data: `/srv/data/`

Example Immich layout:

```
/srv/stacks/immich/
├── docker-compose.yml
├── .env.example
└── (local .env created on VM200)

/srv/data/immich/
├── library/
├── model-cache/
└── pgdata/
```

---

## Networking

### Required Docker Network: `proxy`

Immich must attach to the shared external Docker network used by Traefik:

- Network name: `proxy`
- Type: external

Create once on VM200 (if not already created by reverse-proxy setup):

```bash
docker network create proxy
```

### Networks used by Immich stack

- **proxy** *(external shared network)*  
  Used for Traefik reverse proxy routing.

- **immich** *(internal stack network)*  
  Used for internal container communication.

---

## Configuration

### .env handling (IMPORTANT)

In GitHub you keep:

- `.env.example` *(safe template)*

On VM200 you create:

- `.env` *(real values, never committed)*

Create the real `.env` on VM200:

```bash
cd /srv/stacks/immich
cp .env.example .env
```

Edit `.env` and set required values.

### Required variables (minimum)

Examples (your `.env.example` may include more):

```conf
DB_PASSWORD=your_secure_password
REDIS_HOSTNAME=redis
DB_HOSTNAME=database
```

### Persistent storage paths (standard)

Immich uploads:

- `/srv/data/immich/library` → container upload path

Database:

- `/srv/data/immich/pgdata` → `/var/lib/postgresql/data`

ML cache:

- `/srv/data/immich/model-cache` → `/cache`

---

## Deployment

From inside VM200:

```bash
cd /srv/stacks/immich
docker compose up -d
```

---

## Access Standard

Immich must be accessed through the reverse proxy using **DNS + HTTPS**.

Standard URL example:

- `https://photos.home.ar`

Debug-only access (avoid long-term):

- `http://<vm200-ip>:2283`

Routing is handled by Traefik labels inside:

- `stacks/immich/docker-compose.yml`

Reverse proxy reference:

- `stacks/reverse-proxy/`

---

## Validation

Confirm containers are up:

```bash
docker compose ps
```

Tail logs:

```bash
docker compose logs -f immich-server
```

Confirm DNS and HTTPS routing from your workstation:

```bash
curl -I https://photos.home.ar
```

Expected:

- TLS handshake completes
- Response headers returned
- HTTP status 200/301/302 depending on app state

---

## Updates

Pull latest images and restart:

```bash
docker compose pull
docker compose up -d
```

---

## Hardware Acceleration

**Standard track note:** GPU/VAAPI is **not required** for client-standard baseline.

If you enable VAAPI (research track), document it under `addons-research/` and ensure:

- `/dev/dri` is accessible
- correct driver and permissions exist
- containers are configured with required mounts and groups

---

## Security Notes

Recommended security posture (already reflected in the compose pattern used in this repo):

- Non-root container execution (`1000:1000`)
- `no-new-privileges: true`
- Drop unnecessary Linux capabilities (`cap_drop: ALL`)
- Log rotation enabled (`max-size`, `max-file`)
- No service ports published directly to LAN (Traefik only for 80/443)

---

## Common Commands

Show running containers:

```bash
docker ps
```

Start the stack:

```bash
docker compose up -d
```

Stop the stack:

```bash
docker compose down
```

---

## Notes

- Reverse proxy expects external `proxy` network (Traefik).
- If Immich is exposed publicly, additional security hardening is required.
- Keep `.env` and any secrets out of GitHub.

Next step (stack level):

- Confirm Traefik routing for `photos.home.ar`
- Document backups (VM200 + `/srv/data/immich`) and restore procedure
