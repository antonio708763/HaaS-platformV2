# Automation Ideas (Future Roadmap)

Purpose:
Capture automation concepts for making HaaS-platform deployment feel like a commercial “installer experience”
(download → run → select options → deploy).

Scope:
This document is not a runbook.
It is a planning roadmap for future automation once the reference build is stable and repeatable.

---

## Guiding Goal

Make deployment and support feel like:

- “Next, Next, Finish” (wizard-style)
- one command bootstrap
- repairable and repeatable workflows
- minimal manual configuration

The platform should be deployable with predictable outcomes on standardized hardware.

---

## Current Priority (Right Now)

Before building automation tooling, the following must be complete:

- Reference documentation finished in HaaS-platformV2
- Proxmox host build documented and repeatable
- VM100 Golden Template stable and backed up
- VM200 Docker host deployable from VM100
- One service stack (Immich) deployed cleanly at least twice

Automation begins only after these steps can be repeated without “winging it.”

---

## Future Automation Targets

### Target 1: Single Bootstrap Script

A single entry point that provisions a new node from a clean Proxmox install.

Example:

- one script
- one config file
- one command

Goals:

- creates baseline VM(s)
- applies security hardening
- installs Docker and dependencies
- deploys selected stacks
- produces logs and a success report

---

### Target 2: Profile-Based Deployment

Instead of asking for dozens of options, deployment should use presets.

Example profiles:

- Basic Node (Photos + Files)
- Media Node (Photos + Movies + Music)
- Full Node (Photos + Files + Passwords + DNS)

---

### Target 3: Wizard / Checkbox Installer UX

A UI-driven experience similar to tools like “Windows Debloater.”

Possible interface types:

- terminal menu (TUI)
- lightweight web portal
- CLI tool with prompts

Example options:

- Enable Immich
- Enable reverse proxy
- Enable backups
- Enable remote access
- Enable monitoring

---

### Target 4: OS Install Simplification

Long-term goal:
Reduce Proxmox/OS installation steps to a nearly unattended process.

Possible approaches:

- preconfigured installation image
- PXE boot automation
- unattended Proxmox installation workflow

This is only viable once hardware SKUs are standardized.

---

## Installation Layers (Where Automation Can Live)

### Layer 1: Hypervisor Install (Hardest to Automate)

Includes:

- BIOS settings
- disk layout decisions
- boot mode consistency (UEFI vs Legacy)

Automation potential: medium (best done via standardized hardware + prebuilt images)

---

### Layer 2: Platform Bootstrap (Best Early Automation Target)

Includes:

- VM creation from template
- networking setup
- security baseline
- monitoring agent installation
- backup policies

Automation potential: high

---

### Layer 3: Service Stack Deployment (Best “Wizard UX” Target)

Includes:

- reverse proxy deployment
- stack deployment (Immich, Vaultwarden, etc.)
- DNS naming conventions
- TLS certificates
- updates

Automation potential: very high

---

## Design Requirements

Any automation must be:

- repeatable (safe to rerun)
- idempotent (does not break existing state)
- logged (clear success/failure output)
- reversible (clear rollback path where possible)
- documented (no “magic” steps)

---

## Suggested Milestone Trigger

Automation work begins once the platform can be rebuilt from scratch using documentation alone:

- Proxmox reinstall
- restore VM100 from backup
- clone VM200
- deploy Docker baseline
- deploy Immich stack
- validate access and backups

Once this can be done twice consistently, the checklists become scripts.

---

## Notes

Automation should follow documentation, not replace it.

Documentation is the source of truth.
Automation is the implementation of the documented standard.
