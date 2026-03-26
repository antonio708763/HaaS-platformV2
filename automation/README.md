# Automation

Purpose:  
This directory contains all automation-related assets for HaaS deployments.

This includes:
- Config templates
- Validation scripts
- Future provisioning tools

---

## Structure

- templates/ → Source-of-truth configuration files
- scripts/ → Validation and automation scripts

---

## Workflow

1. Define deployment in `templates/node-config.yml`
2. Run validation scripts after deployment
3. Confirm network passes validation checklist
4. Expand into provisioning automation (future)

---

## Principles

- Automation follows documentation
- Config-driven deployments
- Idempotent scripts (safe to re-run)
- Minimal operator input

---

## Status

- Phase: Initial automation foundation
