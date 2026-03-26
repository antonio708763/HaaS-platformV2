# NetBird Integration Plan

Purpose:  
This document defines how NetBird will be integrated into the HaaS network stack.

---

## Objectives

- Secure remote access to homelab services
- Eliminate need for port forwarding
- Provide zero-trust remote connectivity
- Maintain privacy-first architecture

---

## Placement

NetBird will be deployed in:

- VLAN: SERVERS
- Host: Docker VM (Debian 12 base)

---

## Components

- netbird-management
- netbird-signal
- netbird-dashboard

---

## Requirements

- Domain configured (e.g. yourdomain.com)
- Reverse proxy (Traefik)
- Valid SSL certificates (Let's Encrypt)
- Persistent storage

---

## Network Design

- NetBird services exposed via HTTPS
- Internal communication stays within SERVERS VLAN
- Remote clients connect via WireGuard-based mesh

---

## Security Model

- No direct port forwarding
- Identity-based access
- Encrypted tunnels
- Centralized control

---

## Deployment Phases

1. Prepare domain and DNS
2. Verify Traefik working
3. Deploy NetBird containers
4. Validate TLS
5. Connect first client
6. Validate internal access

---

## Future Enhancements

- SSO integration
- Multi-user access control
- Audit logging
- Automated deployment

---

## Status

- Status: PLANNED
