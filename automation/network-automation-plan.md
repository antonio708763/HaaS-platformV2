# Network Automation Plan

Purpose:  
This document defines the automation strategy for deploying the HaaS Tier-1 network standard in a repeatable and supportable way.

This plan is intended to move the network stack from:
- manual configuration
- operator memory
- UI-only deployment

to:
- config-driven deployment
- standardized validation
- repeatable rollout

---

## Table of Contents

- [Goals](#goals)
- [Automation Boundaries](#automation-boundaries)
- [Deployment Inputs](#deployment-inputs)
- [Tier-1 Baseline Outputs](#tier-1-baseline-outputs)
- [Recommended Repository Layout](#recommended-repository-layout)
- [Phase 1 - Documentation First](#phase-1---documentation-first)
- [Phase 2 - Config Templates](#phase-2---config-templates)
- [Phase 3 - Validation Automation](#phase-3---validation-automation)
- [Phase 4 - Provisioning Automation](#phase-4---provisioning-automation)
- [Phase 5 - Future Integration Targets](#phase-5---future-integration-targets)
- [Notes](#notes)

---

## Goals

The automation system should:

- Deploy the same Tier-1 network model every time
- Reduce operator mistakes
- Preserve a supportable standard
- Keep security controls consistent
- Make validation repeatable
- Support future installer workflows

---

## Automation Boundaries

The following should remain standardized and automatable:

- VLAN definitions
- DHCP ranges
- DNS assignment
- Firewall rule order
- NAT DNS enforcement
- Validation checks
- Device naming conventions

The following should remain manual or operator-reviewed in early phases:

- WAN-specific ISP settings
- Physical cabling
- Final AP placement
- Per-client custom exceptions
- Emergency recovery actions

---

## Deployment Inputs

Recommended inputs for a Tier-1 deployment:

- Router LAN parent interface
- VLAN IDs
- VLAN gateway IPs
- DHCP ranges
- AdGuard primary IP
- AdGuard secondary IP
- AP uplink port
- Switch access/trunk port map

These should eventually be stored in a single config file.

---

## Tier-1 Baseline Outputs

A successful automated deployment should produce:

- Trusted VLAN
- Servers VLAN
- IoT VLAN
- Guest VLAN
- Management VLAN
- DHCP configured per VLAN
- DNS forced through AdGuard
- Public DNS blocked
- DoH baseline blocked
- Validation checklist pass state

---

## Recommended Repository Layout

Recommended placement inside the repository:

```text
HaaS-platformV2/
├── docs/
│   ├── architecture/
│   │   └── network-standard.md
│   ├── deployment/
│   │   └── network-setup.md
│   ├── validation/
│   │   └── network-validation-checklist.md
│   └── automation/
│       └── network-automation-plan.md
│
├── automation/
│   ├── templates/
│   │   └── node-config.example.yml
│   ├── scripts/
│   │   └── validate-network.sh
│   └── README.md
```

---

## Phase 1 - Documentation First

Before automation, the following documents must exist and remain authoritative:

- network-standard.md
- network-setup.md
- network-validation-checklist.md

Automation should be derived from these documents, not replace them.

---

## Phase 2 - Config Templates

Create a single config file to describe a deployment.

Example fields:

- site_name
- vlan_trusted_id
- vlan_servers_id
- vlan_iot_id
- vlan_guest_id
- vlan_mgmt_id
- trusted_gateway
- servers_gateway
- iot_gateway
- guest_gateway
- mgmt_gateway
- adguard_primary
- adguard_secondary
- switch_trunk_port
- switch_ap_port
- switch_proxmox_port

This becomes the source of truth for future automation.

---

## Phase 3 - Validation Automation

First automation target should be validation, not provisioning.

Recommended script goals:

- Verify gateway reachability
- Verify DNS server reachability
- Verify AdGuard web UI reachability
- Verify Proxmox web UI reachability
- Verify forced DNS behavior
- Verify public DNS bypass fails
- Verify expected VLAN addressing

This is low-risk and immediately useful.

---

## Phase 4 - Provisioning Automation

After validation is stable, begin generating:

- switch port maps
- firewall rule checklists
- DHCP option checklists
- NAT rule checklists

Eventually, this can evolve into:

- API-driven router configuration
- switch configuration export/import
- AP deployment templates

Provisioning automation should only be added after the standard is fully stable.

---

## Phase 5 - Future Integration Targets

Longer-term automation targets:

- OPNsense API or config export/import
- TP-Link switch documented config snapshots
- AP SSID/VLAN deployment template
- NetBird server deployment into SERVERS VLAN
- Post-deploy validation runner
- Standardized handoff report generation

---

## Notes

Automation should reinforce the standard, not create parallel logic.

The correct order is:

1. Standardize
2. Document
3. Validate
4. Automate
5. Productize
