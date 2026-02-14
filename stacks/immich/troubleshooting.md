# Immich Troubleshooting (Client Track)

Purpose:
Common issues, error messages, and resolution steps for Immich stack deployment and operation on VM200.

Scope:
HaaS-platformV2 standard track (Traefik reverse proxy, DNS-based access).

This document covers:
- Container startup failures and restart loops
- Database connectivity and initialization problems
- Reverse proxy routing and DNS issues

---

## Table of Contents

- [Quick Checks](#quick-checks)
- [Container Issues](#container-issues)
- [Database Issues](#database-issues)
- [Networking and Traefik Issues](#networking-and-traefik-issues)
- [Notes](#notes)

---

## Quick Checks

Run these first from VM200:

Confirm containers are up:

    cd /srv/stacks/immich
    docker compose ps

Check recent logs:

    docker compose logs --tail=200 immich-server

Confirm proxy network exists:

    docker network ls | grep proxy

Confirm DNS resolves from your workstation:

    ping -c 3 photos.home.ar

---

## Container Issues

### Immich won’t start

Symptom:
`immich-server` exits immediately or never becomes healthy.

Check:

    cd /srv/stacks/immich
    docker compose logs immich-server

Common causes:
- Missing `.env`
- Database not ready yet
- Bad permissions on library directory

Fixes:

Create `.env` (if missing):

    cp .env.example .env

Bring up dependencies first:

    docker compose up -d database redis
    sleep 30
    docker compose up -d

Fix library permissions (host side):

    sudo chown -R 1000:1000 /srv/data/immich/library
    sudo chmod 755 /srv/data/immich/library

---

### Restart loops

Symptom:
Containers restart repeatedly.

Check:

    docker compose ps
    docker compose logs --tail=200 immich-server

Common causes:
- DB_PASSWORD mismatch between services and database

Fix:
Confirm `.env` has the correct DB_PASSWORD value and then restart stack:

    docker compose down
    docker compose up -d

---

## Database Issues

### Postgres won’t start

Symptom:
`immich-postgres` crashes or stays unhealthy.

Check:

    docker compose logs --tail=200 database

Common causes:
- Corrupt data directory
- Bad permissions in /srv/data/immich/pgdata

Fix (permissions):

    sudo chown -R 999:999 /srv/data/immich/pgdata

Last resort (DESTROYS DB DATA):
Only do this if you accept wiping the database:

    docker compose down
    sudo rm -rf /srv/data/immich/pgdata/*
    docker compose up -d

---

### Immich can’t connect to database

Symptom:
`connection refused` or DB auth failures in server logs.

Check:

    docker compose logs --tail=200 immich-server
    docker compose logs --tail=200 database

Fix:
- Ensure `DB_HOSTNAME=database` in `.env`
- Ensure `DB_PASSWORD` matches Postgres password expectations
- Restart stack:

    docker compose down
    docker compose up -d

---

## Networking and Traefik Issues

### Proxy network missing

Symptom:
Compose fails attaching to `proxy`.

Fix (create once):

    docker network create proxy

Then redeploy:

    docker compose up -d

---

### DNS resolves but site won’t load

Symptom:
`https://photos.home.ar` doesn’t load, or returns 404/502.

Check DNS (workstation):

    ping -c 3 photos.home.ar

Check Traefik container is running (VM200):

    docker ps | grep traefik

Check Traefik sees the Immich router:
(If you have Traefik dashboard enabled)

- Open: https://proxy.home.ar
- Confirm router exists: immich
- Confirm service port: 2283

Also confirm Immich is up:

    cd /srv/stacks/immich
    docker compose ps
    docker compose logs --tail=200 immich-server

---

### HTTP works but HTTPS fails

Symptom:
Browser warns about cert or HTTPS won’t establish.

Cause:
Certificate strategy not configured yet (expected in lab).

Fix:
For now, this is normal until you implement the TLS standard you choose (ACME/DNS-01, internal CA, etc.).

---

## Notes

- Always check logs first:
  
      docker compose logs -f immich-server

- Typical startup order:

  database → redis → immich-server → microservices → ml

- When in doubt:

      docker compose down
      docker compose up -d
