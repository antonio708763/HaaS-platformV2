# NetBird (Production) — HaaS Platform V2

## Purpose

NetBird provides secure remote access (mesh VPN) to the HaaS homelab environment.

It is deployed behind Traefik with automatic Let's Encrypt DNS-01 certificates via Cloudflare.

---

## Deployment Details

- Domain: netbird.sotoprivatecloud.com
- Reverse Proxy: Traefik (external)
- TLS: Let's Encrypt (DNS challenge via Cloudflare API token)
- STUN: UDP 3478 exposed on host
- Persistent Data: /srv/data/netbird/server

---

## Architecture

Services:

- netbird-server (combined management + signal + relay + STUN)
- netbird-dashboard (UI)

Networking:

- Docker external network: proxy
- Public TCP 443 → VM200 → Traefik
- Public UDP 3478 → VM200 → netbird-server

---

## Persistence

Data directory:

/srv/data/netbird/server

This directory contains:

- store.db
- idp.db
- events.db
- GeoLite database
- key material and internal state

Loss of this directory = loss of NetBird state.

---

## Restore Procedure

1. Restore /srv/data/netbird/server from backup
2. Ensure correct ownership (root:docker recommended)
3. Restart stack:

   cd /srv/stacks/netbird
   docker compose up -d

4. Verify:
   - https://netbird.sotoprivatecloud.com loads
   - UDP 3478 listening

---

## Verification Commands

Check containers:

    docker compose ps

Check mounts:

    docker inspect netbird-server --format '{{range .Mounts}}{{println .Type .Source "->" .Destination}}{{end}}'

Check STUN:

    sudo ss -u -l -n -p | grep ':3478'

Check TLS:

    curl -vkI https://netbird.sotoprivatecloud.com

---

## Security Notes

- Cloudflare API token stored in Traefik .env
- config.yaml mounted read-only
- ACME storage located at /srv/data/traefik/acme.json

---

## Change Log

Initial production deployment completed:
February 22–23, 2026
