# HaaS Platform Philosophy

Purpose:
Core design principles, business constraints, and decision framework guiding HaaS-platform development.

Scope:
Applies to all technical and business decisions from lab research through client deployments.

This philosophy drives:

- Simple plug-and-play appliances for non-technical residential customers
- Open-source software with a commercial hardware + service model
- Privacy-first, subscription-free alternatives to Big Tech cloud services
- Standardized, remotely manageable infrastructure

---

## Table of Contents

- [Core Principles](#core-principles)
  - [Simplicity](#simplicity)
  - [Privacy](#privacy)
  - [Ownership](#ownership)
  - [Standardization](#standardization)
- [Business Model](#business-model)
  - [Hardware + Service](#hardware--service)
  - [Customer Scope](#customer-scope)
  - [Support Boundaries](#support-boundaries)
- [Technical Constraints](#technical-constraints)
  - [Open Source Priority](#open-source-priority)
  - [Hardware Standardization](#hardware-standardization)
  - [Automation Requirements](#automation-requirements)
- [Decision Framework](#decision-framework)
  - [Technology Choices](#technology-choices)
  - [Security Posture](#security-posture)
- [Notes](#notes)

---

## Core Principles

### Simplicity

Customers plug in one box. One login. Services should "just work."

Requirements:

- No CLI required from end users
- Single web portal (reverse proxy → dashboard)
- Standardized onboarding (5-minute setup call maximum)
- Updates invisible to customers

If a customer must learn Linux to use the product, the product has failed.

---

### Privacy

All data stays local. No cloud scanning, no ads, no tracking.

Requirements:

- Self-hosted = fully client-owned data
- No “phoning home” to company infrastructure
- Encrypted remote support only when requested
- Transparent remote access (opt-in and revocable)

Privacy is a product feature, not a marketing slogan.

---

### Ownership

Customers own the hardware and data forever. No subscriptions required for core services.

Requirements:

- One-time hardware purchase
- Optional service contract for updates/support
- Easy export and restore paths
- No vendor lock-in

---

### Standardization

One SKU → one software stack → one support process.

Requirements:

- Limited hardware choices (2–3 SKUs maximum)
- Identical software across all deployments
- Entire system reproducible from documentation alone
- VM templates + automated stack deployment

Customization is the enemy of supportability.

---

## Business Model

### Hardware + Service

Revenue model:

- Hardware cost → one-time purchase (parts + labor)
- Service contract → recurring revenue (updates, monitoring, support)

Target model (subject to change):

- $300–800 hardware
- $20–50/month support

The platform must remain functional without an active subscription.

---

### Customer Scope

Target customer:

- non-technical residential households
- privacy-conscious individuals
- families wanting private photo backups
- customers tired of iCloud / Google Photos / streaming subscription overload

Not the target customer:

- developers
- enterprise IT teams
- homelab enthusiasts looking for maximum customization

The goal is "appliance simplicity," not "power user flexibility."

---

### Support Boundaries

We support:

- hardware failures → replacement
- software updates → automated
- service downtime → remote restart and recovery

We do not support:

- customer internet problems
- custom software requests
- media format compatibility issues
- user training beyond initial onboarding

Support boundaries exist to protect reliability and profitability.

---

## Technical Constraints

### Open Source Priority

Everything customer-facing must be FOSS.

Allowed examples:

- Nextcloud
- Jellyfin
- Immich
- Vaultwarden
- AdGuard

Not allowed:

- Plex Pass
- OnlyOffice Enterprise
- proprietary SaaS dependencies

Commercial exceptions may exist only for remote management or monitoring tooling.

---

### Hardware Standardization

Hardware requirements:

- 2–3 SKUs maximum
- quiet residential hardware (mini-PC form factor preferred)
- no loud rackmount servers
- no high-maintenance enterprise hardware

Example SKU targets:

**Basic**
- 16GB RAM
- 256GB SSD + 2TB HDD
- iGPU only

**Plus**
- 32GB RAM
- 512GB SSD + 4TB HDD
- discrete GPU (optional)

---

### Automation Requirements

All operations must be scripted or documented.

Operational targets:

- Deploy new node: 30 minutes maximum from bare metal
- Software update: one command (ideally automated)
- Backup restore: ≤ 1 hour RTO (Recovery Time Objective)

If it cannot be automated, it cannot scale.

---

## Decision Framework

### Technology Choices

Accept a technology if it is:

1. Open source (Apache / MIT / GPL)
2. Stable and well documented (LTS preferred)
3. Widely adopted by the homelab community
4. Compatible with plug-and-play UX expectations

Reject a technology if it:

1. Requires daily CLI babysitting
2. Introduces single points of failure
3. Requires undocumented configuration hacks
4. Consumes excessive CPU/RAM for residential hardware

---

### Security Posture

Security model:

- default deny
- least privilege
- automation-friendly

Baseline expectations:

- SSH: keys only, no root login, fail2ban
- Docker: non-root where possible, `no-new-privileges`, minimal capabilities
- Firewall: explicit allow rules only
- Updates: automated, tested on reference builds first

Security must not rely on “remembering to do the right thing.”

---

## Notes

### Target Customer Journey

Day 1:

- unbox
- plug in ethernet
- power on
- quick support call (15 minutes)

Day 2+:

- open dashboard: `https://home.mylastname.local`
- access: Photos / Files / Movies / Passwords

Month 2+:

- “I forgot I even have this running.”

Success metric:

- customer cannot tell if it’s working (because it always is)

---

### Anti-Patterns to Avoid

- “works on my machine” syndrome
- per-customer customizations
- manual intervention for routine tasks
- undocumented CLI hacks

Lab validates business viability. Production requires zero-excuses reliability.
