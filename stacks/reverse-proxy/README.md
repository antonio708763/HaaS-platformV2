# Reverse Proxy Stack (Client Standard)

Purpose:  
This stack provides a standardized reverse proxy entrypoint for all service stacks running on the Docker Host VM (VM200).

The reverse proxy is the foundation of the platform because it enables:

- One consistent access layer for all apps
- Centralized TLS termination (HTTPS)
- Clean routing by hostname (photos.domain.com, vault.domain.com, etc.)
- Standard logging and security controls

Scope:  
Client-ready standard track. This stack is required before deploying production service stacks.

---

## Table of Contents

- [Overview](#overview)
- [Design Goals](#design-goals)
- [Networking Model](#networking-model)
- [Directory Layout](#directory-layout)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Proxy Network Standard](#proxy-network-standard)
- [Validation](#validation)
- [Backup and Restore Notes](#backup-and-restore-notes)
- [Golden Rules](#golden-rules)
- [Next Steps](#next-steps)

---

## Overview

The reverse proxy is deployed as its own Docker Compose stack and connects to a shared external Docker network named:

`proxy`

All other stacks connect to this same network, allowing the proxy to route traffic to them without exposing service ports directly to the LAN.

---

## Design Goals

This reverse proxy stack must support:

- HTTPS (TLS termination)
- Hostname-based routing
- Centralized control of access to internal services
- A single "entry point" architecture for client simplicity

This design ensures that internal stacks are not exposed directly.

---

## Networking Model

Traffic flow:

Client Device → Reverse Proxy → Internal Docker Stack

The reverse proxy is the only stack that should expose ports publicly.

---

## Directory Layout

Reverse proxy stack directory:

<pre><code>
/srv/stacks/reverse-proxy/
├── docker-compose.yml
├── .env
└── README.md
</code></pre>

---

## Prerequisites

Before deployment:

- VM200 is online and stable
- Docker Engine installed and working
- Docker Compose installed and working
- SSH access confirmed
- Directory structure exists:

<pre><code>
/srv/stacks/
</code></pre>

---

## Deployment Steps

### 1. Create the reverse proxy directory

<pre><code class="language-bash">
sudo mkdirF mkdir -p /srv/stacks/reverse-proxy
sudo chown -R $USER:$USER /srv/stacks/reverse-proxy
cd /srv/stacks/reverse-proxy
</code></pre>

---

### 2. Create the shared proxy network

This network must exist before deploying any stack that requires reverse proxy routing.

<pre><code class="language-bash">
docker network create proxy
</code></pre>

Verify:

<pre><code class="language-bash">
docker network ls | grep proxy
</code></pre>

---

### 3. Deploy the reverse proxy stack

The reverse proxy can be implemented using one of the following:

- Traefik (recommended for automation + scaling)
- Nginx Proxy Manager (recommended for GUI simplicity)

Client standard default:

**Nginx Proxy Manager (NPM)**

---

## Proxy Network Standard

All stacks must attach to:

`proxy`

This allows hostname-based routing without exposing container ports directly.

Example requirement for all stacks:

- internal stack network (example: immich)
- external shared network (proxy)

---

## Nginx Proxy Manager (Standard Deployment)

### docker-compose.yml (example)

Create:

`/srv/stacks/reverse-proxy/docker-compose.yml`

<pre><code>
version: "3.8"

services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: reverse-proxy-npm
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - proxy

networks:
  proxy:
    external: true
</code></pre>

---

### Start the reverse proxy stack

<pre><code class="language-bash">
docker compose up -d
</code></pre>

Verify container status:

<pre><code class="language-bash">
docker ps
</code></pre>

---

## Validation

### Confirm ports are listening

Expected exposed ports:

- 80/tcp
- 443/tcp
- 81/tcp (admin UI)

Run:

<pre><code class="language-bash">
ss -tulnp | grep -E "80|443|81"
</code></pre>

---

### Confirm admin UI access

From your workstation:

- http://&lt;vm200-ip&gt;:81

Default login:

- Email: `admin@example.com`
- Password: `changeme`

First login will require setting a new password.

---

### Confirm Docker network connectivity

<pre><code class="language-bash">
docker network inspect proxy
</code></pre>

Expected:

- reverse-proxy-npm container is listed under the proxy network

---

## Backup and Restore Notes

The reverse proxy stack contains critical data:

- SSL certificates
- proxy host definitions
- routing configuration

These must be included in backups.

Minimum required backup data:

<pre><code>
/srv/stacks/reverse-proxy/data/
/srv/stacks/reverse-proxy/letsencrypt/
</code></pre>

---

## Golden Rules

- Reverse proxy must be deployed before any production stack.
- Only reverse proxy exposes ports 80/443 to the LAN.
- Service stacks must not expose application ports unless required for debugging.
- All stacks must attach to the `proxy` network.
- SSL certificates must be backed up.
- Admin UI credentials must be stored securely (never in GitHub).

---

## Next Steps

After reverse proxy is deployed:

1. Deploy a test stack (example: uptime-kuma)
2. Route it through the reverse proxy
3. Validate HTTPS works
4. Begin client-ready stack deployments (Immich, Vaultwarden, etc.)
