# Monitoring Standard (Client Track)

Purpose:  
Define the monitoring baseline for HaaS-platformV2 client deployments.

Monitoring is required to ensure:
- early detection of outages
- predictable support workflows
- SLA-style reliability expectations
- rapid recovery and troubleshooting

Scope:  
Client-ready standard track. Applies to all client nodes and reference builds.

---

## Table of Contents

- [Overview](#overview)
- [Monitoring Platform](#monitoring-platform)
- [Monitoring Goals](#monitoring-goals)
- [Baseline Services to Monitor](#baseline-services-to-monitor)
- [Alerting Standard](#alerting-standard)
- [Notification Methods](#notification-methods)
- [Recommended Check Types](#recommended-check-types)
- [Naming Convention](#naming-convention)
- [Minimum Required Checks](#minimum-required-checks)
- [Incident Response Workflow](#incident-response-workflow)
- [Golden Rules](#golden-rules)

---

## Overview

Monitoring is mandatory for all client-ready deployments.

This platform uses Uptime Kuma as the baseline monitoring stack because it is:

- lightweight
- simple to deploy
- easy to maintain
- client-friendly for uptime reporting

Monitoring is treated as part of the infrastructure baseline, not an optional add-on.

---

## Monitoring Platform

Standard monitoring stack:

- Uptime Kuma (Docker stack on VM200)

Location:

- VM200 Docker Host

Routing:

- Reverse proxy hostname (example: `status.lab.local`)

---

## Monitoring Goals

Monitoring must answer these questions:

- Is the Proxmox host reachable?
- Is the Docker host VM reachable?
- Is the reverse proxy running?
- Are service stacks responding?
- Are critical ports reachable?
- Are backup jobs running consistently?

Monitoring must detect outages quickly and provide actionable information.

---

## Baseline Services to Monitor

### Infrastructure Layer (Host)

Monitor:

- Proxmox WebUI (`https://<host-ip>:8006`)
- Proxmox host ping
- Proxmox host SSH (optional)

---

### VM Layer

Monitor:

- VM200 ping
- VM200 SSH
- VM200 reverse proxy port 80/443 availability

---

### Service Layer

Monitor all deployed stacks, minimum:

- Uptime Kuma itself
- Reverse proxy container
- Immich (if deployed)
- Vaultwarden (if deployed)
- DNS stack (if deployed)
- Monitoring / dashboard stack (if deployed)

---

## Alerting Standard

Alerts must trigger when:

- service becomes unreachable
- health check fails
- reverse proxy stops responding
- stack returns HTTP 500 or timeout

Recommended baseline alert policy:

- notify after 2 consecutive failures
- check interval: 60 seconds
- retry interval: 30 seconds
- mark down after ~2 minutes

---

## Notification Methods

Alerting methods depend on deployment environment.

Recommended alerting methods:

- email (preferred for business use)
- Discord webhook (lab-friendly)
- Telegram (optional)
- SMS (future paid option)

Minimum requirement:

- at least one alert channel must be configured
- alerts must be tested during deployment

---

## Recommended Check Types

Use the simplest check type that matches the service.

Recommended types:

- Ping check (host availability)
- TCP port check (SSH, HTTPS, Proxmox UI)
- HTTP(s) check (apps behind proxy)
- keyword validation (optional, for confirming expected UI content)

---

## Naming Convention

All checks must follow a predictable naming scheme.

Recommended format:

`[Layer] - [Node] - [Service]`

Examples:

- `HOST - labcore01 - Ping`
- `HOST - labcore01 - Proxmox WebUI`
- `VM - VM200 - SSH`
- `STACK - Reverse Proxy - HTTP`
