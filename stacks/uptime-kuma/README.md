# Uptime Kuma Stack (Client Standard)

Purpose:  
This stack deploys **Uptime Kuma**, the standard monitoring dashboard for HaaS-platformV2.

Uptime Kuma provides:
- service uptime monitoring (HTTP/TCP/Ping)
- alerting
- basic availability reporting
- an internal health monitoring UI for client nodes

Scope:  
Client-ready standard track. This stack is part of the baseline monitoring standard.

---

## Table of Contents

- [Overview](#overview)
- [Design Goals](#design-goals)
- [Directory Layout](#directory-layout)
- [Prerequisites](#prerequisites)
- [Networking Model](#networking-model)
- [Deployment Steps](#deployment-steps)
- [Reverse Proxy Integration](#reverse-proxy-integration)
- [Validation](#validation)
- [Backup and Restore Notes](#backup-and-restore-notes)
- [Golden Rules](#golden-rules)
- [Next Steps](#next-steps)

---

## Overview

Uptime Kuma is deployed as a Docker Compose stack on VM200.

It is routed through the reverse proxy stack using the shared external Docker network:

`proxy`

The stack runs internally and should not expose its port directly to the LAN once reverse proxy is working.

---

## Design Goals

This monitoring stack must support:

- persistent uptime data storage
- reverse proxy routing by hostname
- safe restart behavior
- easy backup + restore
- minimal moving parts

---

## Directory Layout

Stack directory:

<pre><code>
/srv/stacks/uptime-kuma/
├── docker-compose.yml
├── README.md
└── data/
</code></pre>

---

## Prerequisites

Before deploying this stack:

- VM200 is online and stable
- Docker Engine is installed and working
- Docker Compose is installed and working
- reverse proxy stack is deployed and working
- Docker network `proxy` exists

Verify proxy network exists:

<pre><code class="language-bash">
docker network ls | grep proxy
</code></pre>

If missing:

<pre><code class="language-bash">
docker network create proxy
</code></pre>

---

## Networking Model

Uptime Kuma uses:

- internal stack network (default compose network)
- external shared proxy network (`proxy`)

Traffic flow:

Client Device → Reverse Proxy → Uptime Kuma

---

## Deployment Steps

### 1. Create the stack directory

<pre><code class="language-bash">
sudo mkdir -p /srv/stacks/uptime-kuma
sudo chown -R $USER:$USER /srv/stacks/uptime-kuma
cd /srv/stacks/uptime-kuma
</code></pre>

---

### 2. Create docker-compose.yml

Create:

`/srv/stacks/uptime-kuma/docker-compose.yml`

<pre><code>
version: "3.8"

services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - ./data:/app/data
    networks:
      - proxy

networks:
  proxy:
    external: true
</code></pre>

---

### 3. Start the stack

<pre><code class="language-bash">
docker compose up -d
</code></pre>

Verify container is running:

<pre><code class="language-bash">
docker ps
</code></pre>

---

## Reverse Proxy Integration

Uptime Kuma runs internally on port:

- `3001`

Once the container is running, add it to Nginx Proxy Manager.

Recommended hostname:

- `status.lab.local` (lab)
- `status.client.local` (client standard)
- `status.yourdomain.com` (future remote access)

Nginx Proxy Manager settings:

- Domain Name: `status.lab.local`
- Scheme: `http`
- Forward Hostname/IP: `uptime-kuma`
- Forward Port: `3001`
- Cache Assets: optional
- Websockets Support: enabled

SSL:
- Lab: optional self-signed
- Production: Let's Encrypt required

---

## Validation

### Confirm container is healthy

<pre><code class="language-bash">
docker ps
docker logs --tail=50 uptime-kuma
</code></pre>

---

### Confirm port is reachable locally

From inside VM200:

<pre><code class="language-bash">
curl -I http://localhost:3001
</code></pre>

Expected:

- HTTP 200 / 302 response

---

### Confirm reverse proxy routing works

From your workstation:

- http://status.lab.local  
or  
- https://status.lab.local

Expected:

- Uptime Kuma web UI loads

---

### Confirm proxy network attachment

<pre><code class="language-bash">
docker network inspect proxy
</code></pre>

Expected:

- uptime-kuma is listed under proxy network containers

---

## Backup and Restore Notes

Uptime Kuma stores all configuration and monitoring history under:

<pre><code>
/srv/stacks/uptime-kuma/data/
</code></pre>

This directory must be included in backup operations.

Minimum restore requirement:

- stack directory restored
- `data/` restored intact
- `docker compose up -d` recreates service with monitoring state preserved

---

## Golden Rules

- Uptime Kuma must always use persistent storage (`./data`).
- Do not store monitoring data inside ephemeral container filesystem.
- Do not expose port 3001 directly to LAN once reverse proxy is confirmed working.
- All monitoring access should flow through reverse proxy routing.
- This stack must remain l
