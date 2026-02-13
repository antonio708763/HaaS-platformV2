# Immich Troubleshooting (Archive)

Purpose:
Document common issues, error messages, and resolution steps for Immich stack deployment and operation.

Scope:
Lab/research troubleshooting only.

This document covers:

- container failures and restart loops
- VAAPI/GPU passthrough problems
- database initialization errors
- reverse proxy connectivity issues

---

## Table of Contents

- [Container Issues](#container-issues)
  - [Service Won't Start](#service-wont-start)
  - [Restart Loops](#restart-loops)
  - [Permission Denied](#permission-denied)
- [GPU / VAAPI Issues](#gpu--vaapi-issues)
  - [No Hardware Acceleration](#no-hardware-acceleration)
  - [vainfo Empty](#vainfo-empty)
  - [Permission on /dev/dri](#permission-on-devdri)
- [Database Issues](#database-issues)
  - [Postgres Won't Start](#postgres-wont-start)
  - [Connection Refused](#connection-refused)
  - [pgvector Extension Missing](#pgvector-extension-missing)
- [Networking Issues](#networking-issues)
  - [Proxy Network Missing](#proxy-network-missing)
  - [Can't Reach Immich](#cant-reach-immich)
  - [Health Check Fails](#health-check-fails)
- [Notes](#notes)
- [Quick Debug Checklist](#quick-debug-checklist)

---

## Container Issues

### Service Won't Start

Symptom:
`docker compose up -d` fails or the container exits immediately.

Check logs:

~~~bash
docker compose logs immich-server
~~~

Common fixes:

**Missing `.env` file**

~~~bash
cp .env.example .env
~~~

**Database not ready (race condition)**

~~~bash
docker compose down
docker compose up -d database redis
sleep 30
docker compose up -d
~~~

---

### Restart Loops

Symptom:
Containers constantly restart (visible in `docker ps`).

Check:

~~~bash
docker ps
docker compose logs --tail=50 immich-server
~~~

Common causes:

**Database password mismatch in `.env`**

Verify:

~~~conf
DB_PASSWORD=your_secure_password
~~~

This must match the Postgres container configuration.

**Redis unavailable**

~~~bash
docker compose logs redis
~~~

---

### Permission Denied

Symptom:
`EACCES: permission denied` errors on the `./library` directory.

Fix:

~~~bash
sudo chown -R 1000:1000 ./library
sudo chmod 755 ./library
~~~

---

## GPU / VAAPI Issues

### No Hardware Acceleration

Symptom:
Immich uses CPU transcoding even when VAAPI is configured.

Verify driver inside the Debian VM:

~~~bash
lspci -nnk | grep -A3 VGA
~~~

Expected:

- `radeon` kernel driver is active

Verify device nodes:

~~~bash
ls -l /dev/dri
~~~

Expected:

- `card*` devices owned by `root:video`
- `renderD128` owned by `root:render`

Fix group membership (inside VM):

~~~bash
sudo usermod -aG video,render $USER
newgrp video
newgrp render
~~~

---

### vainfo Empty

Symptom:
`vainfo` shows no supported profiles.

Test:

~~~bash
export LIBVA_DRIVER_NAME=r600
vainfo
~~~

Expected output includes profiles such as:

- `VAProfileH264...`
- `VAProfileMPEG2...`

If empty, the driver may be incorrect or the GPU may not be accessible.

---

### Permission on /dev/dri

Symptom:
Immich containers cannot access `/dev/dri` even though it exists.

Verify group IDs:

~~~bash
getent group video
getent group render
~~~

Expected:

- `video` → GID 44
- `render` → GID 105

Confirm docker compose includes:

~~~yaml
group_add:
  - "44"
  - "105"
~~~

---

## Database Issues

### Postgres Won't Start

Symptom:
Postgres container crashes immediately.

Check logs:

~~~bash
docker compose logs database
~~~

If the database volume is corrupted or misconfigured, a wipe may be required.

Reset database (DESTRUCTIVE):

~~~bash
docker compose down
docker volume rm haas-platform_pgdata
docker compose up -d
~~~

WARNING:
This wipes the database completely.

---

### Connection Refused

Symptom:
`immich-server` cannot connect to `database`.

Verify container networking:

~~~bash
docker network inspect haas-platform_immich
~~~

All Immich services must appear on the same Docker network.

---

### pgvector Extension Missing

Symptom:
Machine learning features fail or behave incorrectly.

Immich requires `pgvector`.

Expected image:

- `pgvector/pgvector:pg14`

No action is needed if this image is being used.

---

## Networking Issues

### Proxy Network Missing

Symptom:
Docker error indicates the `proxy` network does not exist.

Fix:

~~~bash
docker network create proxy
docker compose up -d
~~~

---

### Can't Reach Immich

Symptom:
Reverse proxy shows `502`, `404`, or connection refused.

Check stack state:

~~~bash
docker compose ps
~~~

Check health endpoint (inside VM):

~~~bash
curl http://immich-server:3001/health
~~~

---

### Health Check Fails

Symptom:
`curl http://immich-server:3001/health` fails.

Interpretation:

- `200 OK` → healthy
- `502 Bad Gateway` → proxy misconfigured
- `Connection refused` → container down or port not listening

---

## Notes

- Always check logs first:

~~~bash
docker compose logs -f immich-server
~~~

- Startup order matters:

`database → redis → immich-server → microservices → machine-learning`

- GPU issues are usually group permissions (`video` / `render`) or driver mismatch.
- Database corruption often requires wiping the database volume.
- Use `docker compose down -v` only as a last resort (it wipes data).

Common log patterns:

Database ready:

- `"database system is ready to accept connections"`

Immich healthy:

- `"Immich has started successfully"`

VAAPI working:

- `"Using VAAPI driver: r600"`

---

## Quick Debug Checklist

- [ ] `docker compose ps` (are all containers Up?)
- [ ] `docker compose logs` (recent errors?)
- [ ] `docker network ls` (proxy + immich networks exist?)
- [ ] `ls -l /dev/dri` (permissions correct?)
- [ ] `cat .env` (passwords match?)
- [ ] `curl http://immich-server:3001/health` (health endpoint works?)
