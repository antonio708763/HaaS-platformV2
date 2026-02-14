# Automation Ideas and Installer Vision (Parking Lot)

Purpose:
Capture “make it feel like an installer” ideas **without** derailing the client-standard build.

Scope:
- This document is **ideas + design direction** only.
- The **client-standard track stays documentation-first** until the reference build is repeatable.

---

## Guiding Principles

- **Idempotent**: safe to re-run; converges to the same desired state.
- **Profiles > flags**: a few bundles (Standard / Standard+Remote / Research Add-ons).
- **Config-driven**: a wizard is just a UI that writes a config file.
- **Safe by default**: destructive actions require explicit confirmation.
- **Observable**: logs + clear status output like a real installer.

---

## What “Installer-like” Means for HaaS

Goal: from the operator’s POV, this should feel like:

1. Install Proxmox (manual or unattended later)
2. Run **one command**
3. System ends in a known-good state with DNS + TLS + stacks deployed

Client experience target:
- Services available via DNS + HTTPS (example: `https://photos.home.ar`)
- Simple onboarding instructions (QR/pairing codes later)

---

## Layers and How Far We Can Go

### 1) Hypervisor / OS Install (Proxmox)
Hardest to “wizard-ify” due to hardware variance.

**Later options:**
- Unattended install (custom ISO / PXE)
- Minimal prompts (disk + hostname)
- Standard post-install hardening steps

**Not a priority until reference build is stable.**

---

### 2) Platform Bootstrap (High ROI)
This is where we can realistically reach “copy one script”.

**Target:** a single bootstrap entry point:
- CLI tool: `haas-bootstrap --profile standard`
- or script: `bootstrap.sh` (versioned) run on the node

Bootstrap responsibilities:
- Validate prerequisites
- Create required directories
- Create required docker networks (example: `proxy`)
- Ensure Traefik is deployed
- Ensure DNS standard is in place (or print what’s required)
- Deploy selected stacks
- Print status report + next steps

---

### 3) Service Layer (Stacks)
Make stacks deployable by profile and toggle:

- photos (Immich)
- vault (Vaultwarden)
- status (Uptime Kuma)
- monitoring (Grafana/Prometheus)

Each stack must have:
- stable directory layout
- `.env.example`
- safe defaults (no secrets committed)
- Traefik labels standardized

---

### 4) Optional “Wizard UI” Wrapper
Once bootstrap is stable:

- TUI menu (ssh in → choose options)
- or minimal web UI

**Important:** UI comes after automation is proven.

---

## Profiles (Bundles)

### Profile: Standard (Client Track)
- VM100 golden template exists
- VM200 docker host exists
- Traefik reverse proxy
- DNS standard enforced (`home.ar`)
- Backup policy enabled and restore drills required

### Profile: Standard + Remote (Future)
- Adds remote access approach (tunnel / controlled exposure)
- Adds certificate strategy fit for remote

### Profile: Research Add-ons
- GPU passthrough
- VAAPI tuning
- experimental stacks

---

## Single Source of Truth: Node Config File

A wizard is a UI that writes a config file.

Proposed file:
- `node-config.yml` (or `node-config.json`)

Suggested fields:
- node name / id
- domain (default `home.ar`)
- vm roles + IPs (or DHCP reservations)
- enabled stacks
- TLS strategy (local CA vs ACME)

---

## Idempotency Rules (Non-negotiable)

- Creating `proxy` network should be safe if it already exists.
- Creating `/srv/stacks` and `/srv/data` should be safe.
- Deploying a stack should be safe to re-run.
- Updates should not wipe data directories.

---

## Safety Rules

Actions that must require explicit confirmation:
- wiping disks
- deleting docker volumes
- removing `/srv/data/*`

---

## Logging and “Installer Output”

Minimum:
- log file written to a known location
- a final summary section:
  - what succeeded
  - what failed
  - what to do next

---

## Automation Candidates (from current docs)

Add a short section like this to the bottom of each runbook.

### VM100 Golden Template
- Verify required services enabled (ssh, guest-agent, fail2ban)
- Apply tmpfiles rule for `/run/sshd`
- Snapshot + backup invocation helpers

### VM200 Docker Host
- Install docker + compose
- Create `/srv/stacks` and `/srv/data`
- Create `proxy` network

### Reverse Proxy (Traefik)
- Deploy Traefik stack
- Initialize `acme.json` permissions (as required)
- Deploy dynamic config files

### Domain/DNS Standard
- Validate DNS resolution for standard names
- Print required DNS records (A / wildcard)

### Immich Stack
- Create data directories
- Copy `.env.example` → `.env` (interactive prompt)
- Deploy stack + health check

---

## Current Plan (Do Not Derail)

1. Finish client-standard documentation
2. Repeat the reference build at least twice from docs alone
3. Convert “Automation Candidates” into scripts/playbooks
4. Wrap scripts with a wizard UI later
